// Copyright SECURRENCY INC.
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

    ///             ///
    ///    Task 1   ///
    ///             ///

/**
 * Implemenet the function "doStringsMatch"
 * if the strings match - return true
 * else - return false
 */
contract StringMatch {

    function doStringsMatch(string memory a, string memory b) external pure returns (bool)
    {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

    ///             ///
    ///    Task 2   ///
    ///             ///

/**
 * Test task "Investor registration"
 *
 * Change the code so that investor details are tied to a "round" 
 * The caller should be able to set the investor details for the first round, then second round, to n... round
 * The caller should be able to retrieve investor details by "round"
 * 
 * All other modifications are allowed.
 **/
contract InvestorRegistration {

    struct InvestorDetails {
        address investor;
        uint64 deposit;
        uint8 investorsAge;
        bool kyc;
        bool verificationStatus;
        bool USResident;
    }

    struct RoundInfo {
        InvestorDetails details;
        uint40 maturity;
        uint40 lastAccrued;
        uint32 rateBps;
    }

    // these bounds ensure our calcs don't revert and
    // the results are the right size
    uint256 constant MAX_RATE_BPS = 100_000; // 1000%
    uint256 constant MAX_TIME_DELTA = 10 * 365 days;

    uint256 public investmentRound = 1;

    address public owner;
    address public newOwner;

    mapping(uint256 => InvestorDetails) private _roundToDetails;
    mapping(uint256 => RoundInfo) private _rounds;

    event LeadInvestorSet(uint256 indexed round, address indexed investor, uint64 deposit);
    event OwnershipTransferred(address oldOwner, address newOwner);
    event OwnershipAccepted(address owner);
    event InterestAccrued(uint256 round, uint256 interest);

    error Unauthorized();
    error InvalidAddress();
    error NonPositiveDeposit(uint64 deposit);
    error InvestorNotAdult(uint8 age);
    error InvestorNotKyc();
    error InvestorNotVerified();
    error InvestorNotUsResident();
    error InterestOverflow();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender, Unauthorized());
        _;
    }

    /**
     * @notice access control functions
     *
     *         This ownership transfer scheme is safer than what
     *         is typically used as it allows the original owner
     *         to recover control if the new address is incorrect.
     *
     *  @param _newOwner The new controller of the contract.
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        newOwner = _newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

    function acceptOwnership() external {
        require(newOwner == msg.sender, Unauthorized());
        owner = newOwner;
        newOwner = address(0);
        emit OwnershipAccepted(owner);
    }
    
    /**
     * @notice Lead investor registration
     * 
     * @param investor A lead investor address
     * @param depositAmount The amount deposited by a investor
     * @param age Investor age
     * @param kycStatus Investor KYC status
     * @param isVerifiedInvestor Investor verification status
     * @param isUSResident Resident status
     **/
    function setLeadInvestorForARound(
        address investor,
        uint64 depositAmount,
        uint8 age,
        bool kycStatus,
        bool isVerifiedInvestor,
        bool isUSResident
    )
        external onlyOwner
    {
        require(investor != address(0x00), InvalidAddress());
        require(depositAmount > 0, NonPositiveDeposit(depositAmount));
        require(age > 18, InvestorNotAdult(age));
        require(kycStatus, InvestorNotKyc());
        require(isVerifiedInvestor, InvestorNotVerified());
        require(isUSResident, InvestorNotUsResident());

        InvestorDetails memory details = InvestorDetails(
            investor,
            depositAmount,
            age,
            kycStatus,
            isVerifiedInvestor,
            isUSResident
        );

        _roundToDetails[investmentRound] = details;
        
        investmentRound++;

        emit LeadInvestorSet(investmentRound, investor, depositAmount);
    }
    
    /**
     * @notice Returns a lead investor details
     * @dev we can get a free getter by making `roundToDetails` public
     *      but encapsulation is not a bad idea, esp when we foresee
     *      further work or upgradability being added.
     **/
    function getInvestorDetailsByInvestmentRound(uint round)
        external
        view
        returns (InvestorDetails memory)
    {
        return _roundToDetails[round];
    }

    function setRate(uint256 round, uint32 rateBps, uint40 maturity) external onlyOwner {
        require(rateBps < MAX_RATE_BPS, "Rate is too high");
        require(maturity > block.timestamp, "Maturity must be in the future");
        require(maturity - block.timestamp < MAX_TIME_DELTA, "Maturity is too far in the future");
        _accrueInterest(round);
        _rounds[round].rateBps = rateBps;
        _rounds[round].maturity = maturity;
    }

    function accrueInterest(uint256 round) external {
        _accrueInterest(round);
    }

    function _accrueInterest(uint256 round) internal {
        RoundInfo storage r = _rounds[round];

        uint256 end = block.timestamp < r.maturity ? block.timestamp : r.maturity;
        uint256 dt = end - r.lastAccrued;
        if (dt == 0) return;

        // numerator will never cause an overflow revert
        // due to our explicit caps;
        // interest will also be much smaller than type(uint64).max
        uint256 interest = r.details.deposit * r.rateBps * dt / 10_000 / (365 days);
        uint64 total = r.details.deposit + uint64(interest);
        r.details.deposit = uint64(total);
        r.lastAccrued = uint40(end);

        emit InterestAccrued(round, interest);
    }
}

    ///             ///
    ///    Task 3   ///
    ///             ///

/**
 * This contract should compile
 * A stack overflow issue
 */
contract StackOverflow {

    struct Currency {
        address currency;
        address settlementCurrency;
    }

    struct Interest {
        int nominalInterestRate;
        int accruedInterest;
        int rateMultiplier;
    }

    struct Date {
        uint contractDealDate;
        uint statusDate;
        uint initialExchangeDate;
        uint maturityDate;
        uint purchaseDate;        
        uint capitalizationEndDate;
        uint cycleAnchorDateOfInterestPayment;
        uint cycleAnchorDateOfRateReset;
        uint cycleAnchorDateOfScalingIndex;
        uint cycleAnchorDateOfFee;
    }

    function createAssetDetails(
        Currency memory currency,
        bytes32 marketObjectCodeRateReset,
        int notionalPrincipal,
        Interest memory interest,
        Date memory date
    )
        external
    {
        require(currency.currency != address(0x00), "Invalid currency address");
        require(currency.settlementCurrency != address(0x00), "Invalid settlement currency address");
        require(marketObjectCodeRateReset != bytes32(0x00), "Code rate request is required");
        require(notionalPrincipal != 0, "notionalPrincipalnotionalPrincipal can't be empty");
        require(interest.nominalInterestRate != 0, "nominalInterestRate can't be empty");
        require(interest.accruedInterest != 0, "accruedInterest can't be empty");
        require(interest.rateMultiplier != 0, "rateMultiplier can't be empty");
        require(date.contractDealDate != 0, "Contract deal date can't be empty");
        require(date.statusDate != 0, "statusDate can't be empty");
        require(date.initialExchangeDate != 0, "initialExchangeDate can't be empty");
        require(date.maturityDate != 0, "maturityDate can't be empty");
        require(date.purchaseDate != 0, "purchaseDate can't be empty");
        require(date.capitalizationEndDate != 0, "capitalizationEndDate can't be empty");
        require(date.cycleAnchorDateOfInterestPayment != 0, "cycleAnchorDateOfInterestPayment can't be empty");
        require(date.cycleAnchorDateOfScalingIndex != 0, "cycleAnchorDateOfScalingIndex can't be empty");
        require(date.cycleAnchorDateOfFee != 0, "cycleAnchorDateOfFee can't be empty");
        
        saveDetailsToStorage(
            currency,
            marketObjectCodeRateReset,
            notionalPrincipal,
            interest,
            date
        );
    }
    
    function saveDetailsToStorage(
        Currency memory currency,
        bytes32 marketObjectCodeRateReset,
        int notionalPrincipal,
        Interest memory interest,
        Date memory date
    )
        internal
    {
        // Mock function
        // skip implementation
    }
}

/**
 *
 *
 *
 *
 *
 *
 *
 */

