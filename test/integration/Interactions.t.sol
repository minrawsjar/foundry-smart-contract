// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CodeConstants} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";

contract InteractionsTest is CodeConstants, Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;
    address account = makeAddr("account");
    address link = makeAddr("link");
    uint256 public constant FUND_AMOUNT = 3 ether;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testCreateSubscription() public {
        CreateSubscription createSub = new CreateSubscription();
        (uint256 subId, address coordinator) = createSub.createSubscription(
            vrfCoordinator,
            account
        );

        assertEq(coordinator, vrfCoordinator);
        assertGt(subId, 0, "Subscription ID should be greater than zero");
    }

    function testFundSubscription() public {
        // Create new subscription first
        CreateSubscription createSub = new CreateSubscription();
        (uint256 subId, ) = createSub.createSubscription(
            vrfCoordinator,
            account
        );

        FundSubscription fundSub = new FundSubscription();
        fundSub.fundSubscription(vrfCoordinator, subId, link, account);

        if (block.chainid == LOCAL_CHAIN_ID) {
            uint96 balance = VRFCoordinatorV2_5Mock(vrfCoordinator)
                .getSubscriptionBalance(subId);
            assertEq(
                balance,
                uint96(FUND_AMOUNT * 100),
                "Mock subscription balance mismatch"
            );
        } else {
            assertTrue(true);
        }
    }

    function testAddConsumer() public {
        // 1. Create subscription
        CreateSubscription createSub = new CreateSubscription();
        (uint256 subId, ) = createSub.createSubscription(
            vrfCoordinator,
            account
        );

        // 2. Fund subscription
        FundSubscription fundSub = new FundSubscription();
        fundSub.fundSubscription(vrfCoordinator, subId, link, account);

        // 3. Add raffle as a consumer
        AddConsumer addConsumerScript = new AddConsumer();
        addConsumerScript.addConsumer(
            address(raffle),
            vrfCoordinator,
            subId,
            account
        );

        // 4. Assert that the raffle contract is now a consumer
        bool isAdded = VRFCoordinatorV2_5Mock(vrfCoordinator).consumerIsAdded(
            subId,
            address(raffle)
        );
        assertTrue(isAdded, "Raffle contract was not added as a VRF consumer");
    }

    function testCreateSubscriptionUsingConfig() public {
        CreateSubscription createSub = new CreateSubscription();
        (uint256 subId, address coordinator) = createSub
            .createSubscriptionUsingConfig();

        // You want to assert that the subId is non-zero and
        // that the coordinator matches what your HelperConfig returns
        assertGt(subId, 0);

        HelperConfig helper = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helper.getConfig();
        assertEq(coordinator, config.vrfCoordinator);
    }
}
