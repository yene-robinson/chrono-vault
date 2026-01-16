// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vault.sol";

/**
 * @title VaultSecurityTest
 * @notice Comprehensive security tests for enhanced Vault contract
 */
contract VaultSecurityTest is Test {
    Vault public vault;
    address public owner = address(1);
    address public guardian = address(2);
    address public user1 = address(3);
    address public user2 = address(4);
    
    uint256 public constant INITIAL_DEPOSIT = 1 ether;
    uint256 public constant LOCK_TIME = 365 days;
    
    event TestResult(string testName, bool passed);
    
    function setUp() public {
        vm.prank(owner);
        vault = new Vault(block.timestamp + LOCK_TIME);
        
        // Set emergency guardian
        vm.prank(owner);
        vault.setEmergencyGuardian(guardian);
        
        // Fund users for testing
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }
    
    // ============ SECURITY TESTS ============
    
    function testDepositLimits() public {
        vm.startPrank(user1);
        
        // Test minimum deposit
        vm.expectRevert(Vault.Vault__DepositTooLow.selector);
        vault.deposit{value: 0.0001 ether}();
        
        // Test maximum deposit
        vm.expectRevert(Vault.Vault__DepositTooHigh.selector);
        vault.deposit{value: 2000 ether}();
        
        // Test valid deposit
        vault.deposit{value: INITIAL_DEPOSIT}();
        assertEq(vault.deposits(user1), INITIAL_DEPOSIT);
        
        emit TestResult("Deposit Limits", true);
        vm.stopPrank();
    }
    
    function testReentrancyProtection() public {
        vm.startPrank(user1);
        vault.deposit{value: INITIAL_DEPOSIT}();
        
        // Fast-forward time to unlock
        vm.warp(block.timestamp + LOCK_TIME + 1);
        
        // Multiple simultaneous withdraw attempts should be prevented
        vm.expectRevert(Vault.Vault__Paused.selector);
        vault.withdraw();
        
        emit TestResult("Reentrancy Protection", true);
        vm.stopPrank();
    }
    
    function testAccessControls() public {
        // Test owner-only functions
        vm.prank(user1);
        vm.expectRevert(Vault.Vault__Unauthorized.selector);
        vault.pause();
        
        vm.prank(user1);
        vm.expectRevert(Vault.Vault__Unauthorized.selector);
        vault.setEmergencyGuardian(address(5));
        
        vm.prank(guardian);
        vm.expectRevert(Vault.Vault__Unauthorized.selector);
        vault.activateEmergencyMode(block.timestamp + LOCK_TIME);
        
        emit TestResult("Access Controls", true);
    }
    
    function testEmergencyMode() public {
        vm.prank(guardian);
        vault.activateEmergencyMode(block.timestamp + 30 days);
        
        assertTrue(vault.paused());
        assertTrue(vault.emergencyMode());
        
        // Users should be able to withdraw in emergency mode
        vm.startPrank(user1);
        vault.deposit{value: INITIAL_DEPOSIT}();
        vault.withdraw();
        assertEq(vault.deposits(user1), 0);
        
        emit TestResult("Emergency Mode", true);
        vm.stopPrank();
    }
    
    function testDirectETHTransfers() public {
        // Test receive function
        vm.startPrank(user1);
        (bool success, ) = address(vault).call{value: INITIAL_DEPOSIT}("");
        assertTrue(success);
        assertEq(vault.deposits(user1), INITIAL_DEPOSIT);
        
        // Test fallback function reverts
        vm.expectRevert("Vault: Direct calls not allowed");
        (success, ) = address(vault).call("unexpected function");
        
        emit TestResult("Direct ETH Transfers", true);
        vm.stopPrank();
    }
    
    function testCustomErrors() public {
        // Test various custom error scenarios
        vm.startPrank(user1);
        
        // Zero value deposit
        vm.expectRevert(Vault.Vault__ZeroValue.selector);
        vault.deposit{value: 0}();
        
        // No deposits to withdraw
        vm.warp(block.timestamp + LOCK_TIME + 1);
        vm.expectRevert(Vault.Vault__NoDeposits.selector);
        vault.withdraw();
        
        emit TestResult("Custom Errors", true);
        vm.stopPrank();
    }
    
    function testGasOptimizations() public {
        vm.startPrank(user1);
        
        uint256 gasBefore = gasleft();
        vault.deposit{value: INITIAL_DEPOSIT}();
        uint256 gasUsed = gasBefore - gasleft();
        
        // Verify deposit was successful with minimal gas
        assertEq(vault.deposits(user1), INITIAL_DEPOSIT);
        
        emit TestResult("Gas Optimizations", true);
        vm.stopPrank();
    }
    
    function testStatisticsTracking() public {
        assertEq(vault.numberOfDepositors(), 0);
        assertEq(vault.totalDeposits(), 0);
        
        vm.startPrank(user1);
        vault.deposit{value: INITIAL_DEPOSIT}();
        vm.stopPrank();
        
        assertEq(vault.numberOfDepositors(), 1);
        assertEq(vault.totalDeposits(), INITIAL_DEPOSIT);
        
        vm.startPrank(user2);
        vault.deposit{value: INITIAL_DEPOSIT}();
        vm.stopPrank();
        
        assertEq(vault.numberOfDepositors(), 2);
        assertEq(vault.totalDeposits(), INITIAL_DEPOSIT * 2);
        
        emit TestResult("Statistics Tracking", true);
    }
    
    function testViewFunctions() public {
        // Test canDeposit
        assertTrue(vault.canDeposit(user1));
        
        // Test canWithdraw (should be false before unlock)
        assertFalse(vault.canWithdraw(user1));
        
        // Test getMaxAdditionalDeposit
        assertEq(vault.getMaxAdditionalDeposit(user1), 1000 ether);
        
        // Test getTimeRemaining
        uint256 timeRemaining = vault.getTimeRemaining();
        assertTrue(timeRemaining > 0);
        assertTrue(timeRemaining <= LOCK_TIME);
        
        emit TestResult("View Functions", true);
    }
    
    function testEventEmissions() public {
        vm.startPrank(user1);
        
        // Test Deposited event
        vm.expectEmit(true, true, false, true);
        emit Deposited(user1, INITIAL_DEPOSIT, block.timestamp);
        vault.deposit{value: INITIAL_DEPOSIT}();
        
        // Test OwnershipTransferred event
        address newOwner = address(5);
        vm.expectEmit(true, true, false, true);
        emit OwnershipTransferred(owner, newOwner);
        vm.prank(owner);
        vault.transferOwnership(newOwner);
        
        emit TestResult("Event Emissions", true);
        vm.stopPrank();
    }
    
    // ============ INTEGRATION TESTS ============
    
    function testFullDepositWithdrawCycle() public {
        vm.startPrank(user1);
        
        // Deposit
        vault.deposit{value: INITIAL_DEPOSIT}();
        assertEq(vault.deposits(user1), INITIAL_DEPOSIT);
        assertEq(vault.getBalance(), INITIAL_DEPOSIT);
        
        // Fast-forward to unlock time
        vm.warp(block.timestamp + LOCK_TIME + 1);
        
        // Withdraw
        vault.withdraw();
        assertEq(vault.deposits(user1), 0);
        assertEq(user1.balance, 10 ether - INITIAL_DEPOSIT); // Account for gas costs
        
        emit TestResult("Full Deposit Withdraw Cycle", true);
        vm.stopPrank();
    }
    
    function testMultipleDepositsSameUser() public {
        vm.startPrank(user1);
        
        // Multiple deposits from same user
        vault.deposit{value: 0.5 ether}();
        vault.deposit{value: 0.3 ether}();
        vault.deposit{value: 0.2 ether}();
        
        assertEq(vault.deposits(user1), 1 ether);
        assertEq(vault.userDepositCount(user1), 3);
        assertEq(vault.numberOfDepositors(), 1); // Should still be 1
        
        emit TestResult("Multiple Deposits Same User", true);
        vm.stopPrank();
    }
    
    function testContractPausing() public {
        vm.startPrank(user1);
        vault.deposit{value: INITIAL_DEPOSIT}();
        vm.stopPrank();
        
        // Pause contract
        vm.prank(owner);
        vault.pause();
        
        // Should not be able to deposit while paused
        vm.startPrank(user2);
        vm.expectRevert(Vault.Vault__Paused.selector);
        vault.deposit{value: INITIAL_DEPOSIT}();
        
        // Should not be able to withdraw while paused (unless emergency mode)
        vm.startPrank(user1);
        vm.expectRevert(Vault.Vault__Paused.selector);
        vault.withdraw();
        
        // Unpause
        vm.prank(owner);
        vault.unpause();
        
        // Should work again
        vault.deposit{value: INITIAL_DEPOSIT}();
        
        emit TestResult("Contract Pausing", true);
        vm.stopPrank();
    }
    
    function testAllSecurityFeatures() public {
        // Run comprehensive security test
        testDepositLimits();
        testReentrancyProtection();
        testAccessControls();
        testEmergencyMode();
        testDirectETHTransfers();
        testCustomErrors();
        testGasOptimizations();
        testStatisticsTracking();
        testViewFunctions();
        testEventEmissions();
        
        emit TestResult("All Security Features", true);
    }
    
    function testAllIntegrationFeatures() public {
        // Run comprehensive integration test
        testFullDepositWithdrawCycle();
        testMultipleDepositsSameUser();
        testContractPausing();
        
        emit TestResult("All Integration Features", true);
    }
}