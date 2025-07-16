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
    uint256 public investmentRound = 1;

    mapping(uint => InvestorDetails) private roundToDetails;

    struct InvestorDetails {
        address investor;
        uint64 deposit;
        uint8 investorsAge;
        bool kyc;
        bool verificationStatus;
        bool USResident;
    }

    event LeadInvestorSet(uint256 indexed round, address indexed investor, uint64 deposit);

    error InvalidAddress();
    error NonPositiveDeposit(uint64 deposit);
    error InvestorNotAdult(uint8 age);
    error InvestorNotKyc();
    error InvestorNotVerified();
    error InvestorNotUsResident();
    
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
        external
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

        roundToDetails[investmentRound] = details;
        
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
        return roundToDetails[round];
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

    struct Stuff {
        bytes32 marketObjectCodeRateReset;
        int notionalPrincipal;
        int nominalInterestRate;
        int accruedInterest;
        int rateMultiplier;
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
        // address currency,
        // address settlementCurrency,
        Currency memory currency,
        Stuff memory stuff
    )
        external
    {
        require(currency.currency != address(0x00), "Invalid currency address");
        require(currency.settlementCurrency != address(0x00), "Invalid settlement currency address");
        require(stuff.marketObjectCodeRateReset != bytes32(0x00), "Code rate request is required");
        require(stuff.notionalPrincipal != 0, "notionalPrincipalnotionalPrincipal can't be empty");
        require(stuff.nominalInterestRate != 0, "nominalInterestRate can't be empty");
        require(stuff.accruedInterest != 0, "accruedInterest can't be empty");
        require(stuff.rateMultiplier != 0, "rateMultiplier can't be empty");
        require(stuff.contractDealDate != 0, "Contract deal date can't be empty");
        require(stuff.statusDate != 0, "statusDate can't be empty");
        require(stuff.initialExchangeDate != 0, "initialExchangeDate can't be empty");
        require(stuff.maturityDate != 0, "maturityDate can't be empty");
        require(stuff.purchaseDate != 0, "purchaseDate can't be empty");
        require(stuff.capitalizationEndDate != 0, "capitalizationEndDate can't be empty");
        require(stuff.cycleAnchorDateOfInterestPayment != 0, "cycleAnchorDateOfInterestPayment can't be empty");
        require(stuff.cycleAnchorDateOfScalingIndex != 0, "cycleAnchorDateOfScalingIndex can't be empty");
        require(stuff.cycleAnchorDateOfFee != 0, "cycleAnchorDateOfFee can't be empty");
        
        saveDetailsToStorage(
            currency,
            stuff
        );
    }
    
    function saveDetailsToStorage(
        // address currency,
        // address settlementCurrency,
        // bytes32 marketObjectCodeRateReset,
        // int notionalPrincipal,
        // int nominalInterestRate,
        // int accruedInterest,
        // int rateMultiplier, 
        // uint contractDealDate,
        // uint statusDate,
        // uint initialExchangeDate,
        // uint maturityDate,
        // uint purchaseDate,
        // uint capitalizationEndDate,
        // uint cycleAnchorDateOfInterestPayment,
        // uint cycleAnchorDateOfRateReset,
        // uint cycleAnchorDateOfScalingIndex,
        // uint cycleAnchorDateOfFee
        Currency memory currency,
        Stuff memory stuff
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

