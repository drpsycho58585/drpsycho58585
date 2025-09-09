// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
 Minimal escrow for single listing "Dr_psycho58".
 - PRICE (seller net) = 3000 TON
 - COMMISSION (5%) = 150 TON
 - BUYER pays TOTAL = 3150 TON
 - sellerPayout intentionally left blank; owner should set it after deploy
 - TIMEOUT = 48 hours (buyer can refund after purchase if seller doesn't confirm)
 Units: nanoTON (1 TON = 1e9 nanoTON)
*/

contract FragmentEscrowForDrPsycho {
    uint8 public constant COMMISSION_PCT = 5;
    uint256 public constant NANO = 10**9;
    uint256 public constant PRICE = 3000 * NANO;
    uint256 public constant COMMISSION = (PRICE * COMMISSION_PCT) / 100;
    uint256 public constant TOTAL = PRICE + COMMISSION;

    uint256 public constant TIMEOUT_SECONDS = 48 * 3600;

    address public owner;
    address payable public platform; // platform / arbiter & commission recipient
    address payable public sellerPayout; // set by owner after deploy
    address public buyer;
    uint256 public purchasedAt;

    enum State { Open, Purchased, Confirmed, Refunded }
    State public state;

    bool private locked;

    string public constant TELEGRAM_USERNAME = "Dr_psycho58";

    event Purchased(address indexed buyer, uint256 amount, uint256 at);
    event Confirmed(address indexed by, uint256 sellerAmount, uint256 platformAmount);
    event Refunded(address indexed buyer, uint256 amount);
    event PlatformSet(address indexed platform);
    event SellerPayoutSet(address indexed sellerPayout);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier onlyPlatform() {
        require(platform != address(0), "platform not set");
        require(msg.sender == platform, "only platform");
        _;
    }

    modifier noReentrant() {
        require(!locked, "reentrant");
        locked = true;
        _;
        locked = false;
    }

    constructor(address payable _platform) {
        owner = msg.sender;
        platform = _platform; // can be address(0) and set later via setPlatform
        state = State.Open;
    }

    function setPlatform(address payable _platform) external onlyOwner {
        require(_platform != address(0), "zero platform");
        platform = _platform;
        emit PlatformSet(_platform);
    }

    // Set seller payout address (callable by owner)
    function setSellerPayout(address payable _sellerPayout) external onlyOwner {
        require(_sellerPayout != address(0), "zero seller");
        sellerPayout = _sellerPayout;
        emit SellerPayoutSet(_sellerPayout);
    }

    // Buyer purchases by sending EXACTLY TOTAL (PRICE + COMMISSION).
    function purchase() external payable noReentrant {
        require(state == State.Open, "not open");
        require(msg.value == TOTAL, "send exactly price + commission (3150 TON)");
        buyer = msg.sender;
        purchasedAt = block.timestamp;
        state = State.Purchased;
        emit Purchased(buyer, msg.value, purchasedAt);
    }

    // Seller confirms off-chain transfer. Only sellerPayout address can call.
    function confirmSale() external noReentrant {
        require(state == State.Purchased, "not purchased");
        require(sellerPayout != address(0), "seller payout not set");
        require(msg.sender == sellerPayout, "only seller payout address can confirm");
        require(platform != address(0), "platform not set");

        state = State.Confirmed;

        uint256 sellerAmount = PRICE;
        uint256 platformAmount = COMMISSION;

        (bool ok1, ) = sellerPayout.call{value: sellerAmount}("");
        require(ok1, "transfer to seller failed");

        (bool ok2, ) = platform.call{value: platformAmount}("");
        require(ok2, "transfer to platform failed");

        emit Confirmed(msg.sender, sellerAmount, platformAmount);
    }

    // Buyer can refund after TIMEOUT_SECONDS if seller didn't confirm
    function claimTimeoutAndRefund() external noReentrant {
        require(state == State.Purchased, "not purchased");
        require(msg.sender == buyer, "only buyer");
        require(block.timestamp >= purchasedAt + TIMEOUT_SECONDS, "timeout not reached");

        state = State.Refunded;

        uint256 refundAmount = TOTAL;
        (bool ok, ) = payable(buyer).call{value: refundAmount}("");
        require(ok, "refund failed");

        emit Refunded(buyer, refundAmount);
    }

    // Platform (Fragment) resolves dispute: releaseToSeller==true -> pay seller+platform; else refund buyer
    function resolveDispute(bool releaseToSeller) external onlyPlatform noReentrant {
        require(state == State.Purchased, "wrong state");

        if (releaseToSeller) {
            require(sellerPayout != address(0), "seller payout not set");
            state = State.Confirmed;

            uint256 sellerAmount = PRICE;
            uint256 platformAmount = COMMISSION;

            (bool ok1, ) = sellerPayout.call{value: sellerAmount}("");
            require(ok1, "transfer to seller failed");

            (bool ok2, ) = platform.call{value: platformAmount}("");
            require(ok2, "transfer to platform failed");

            emit Confirmed(msg.sender, sellerAmount, platformAmount);
        } else {
            state = State.Refunded;
            uint256 refundAmount = TOTAL;
            (bool ok, ) = payable(buyer).call{value: refundAmount}("");
            require(ok, "refund failed");
            emit Refunded(buyer, refundAmount);
        }
    }

    // Emergency: owner withdraw only if still open
    function ownerWithdraw(uint256 amount, address payable to) external onlyOwner noReentrant {
        require(state == State.Open, "withdraw only when open");
        require(to != address(0), "zero to");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "withdraw failed");
    }

    receive() external payable {
        revert("use purchase()");
    }

    fallback() external payable {
        revert("fallback");
    }
