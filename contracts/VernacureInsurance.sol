// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VernacureInsurance
 * @dev Smart contract for managing insurance policies on Avalanche blockchain
 * @notice Hackathon project for AI IGNITE 2026 - Vernacure InsurTech Platform
 */
contract VernacureInsurance {
    
    struct Policy {
        uint256 policyId;
        address owner;
        string ipfsHash;
        string policyType;
        string insurerName;
        uint256 premium;
        uint256 coverage;
        uint256 purchaseDate;
        bool isActive;
    }
    
    mapping(uint256 => Policy) public policies;
    mapping(address => uint256[]) public userPolicies;
    uint256 public policyCounter;
    address public admin;
    
    event PolicyPurchased(
        uint256 indexed policyId,
        address indexed owner,
        string ipfsHash,
        string policyType,
        uint256 premium,
        uint256 coverage
    );
    
    event PolicyDeactivated(uint256 indexed policyId, address indexed owner);
    event ClaimFiled(uint256 indexed policyId, address indexed owner, uint256 claimAmount);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    modifier onlyPolicyOwner(uint256 _policyId) {
        require(policies[_policyId].owner == msg.sender, "Not policy owner");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        policyCounter = 0;
    }
    
    /**
     * @dev Purchase a new insurance policy
     * @param _ipfsHash IPFS hash of policy documents
     * @param _policyType Type of insurance (Health, Life, Term, etc.)
     * @param _insurerName Name of the insurer
     * @param _coverage Coverage amount in wei
     */
    function purchasePolicy(
        string memory _ipfsHash,
        string memory _policyType,
        string memory _insurerName,
        uint256 _coverage
    ) external payable returns (uint256) {
        require(msg.value > 0, "Premium must be greater than 0");
        require(bytes(_ipfsHash).length > 0, "IPFS hash required");
        
        policyCounter++;
        
        policies[policyCounter] = Policy({
            policyId: policyCounter,
            owner: msg.sender,
            ipfsHash: _ipfsHash,
            policyType: _policyType,
            insurerName: _insurerName,
            premium: msg.value,
            coverage: _coverage,
            purchaseDate: block.timestamp,
            isActive: true
        });
        
        userPolicies[msg.sender].push(policyCounter);
        
        emit PolicyPurchased(
            policyCounter,
            msg.sender,
            _ipfsHash,
            _policyType,
            msg.value,
            _coverage
        );
        
        return policyCounter;
    }
    
    /**
     * @dev Get policy details by ID
     */
    function getPolicy(uint256 _policyId) external view returns (Policy memory) {
        require(_policyId > 0 && _policyId <= policyCounter, "Invalid policy ID");
        return policies[_policyId];
    }
    
    /**
     * @dev Get all policies owned by an address
     */
    function getUserPolicies(address _user) external view returns (uint256[] memory) {
        return userPolicies[_user];
    }
    
    /**
     * @dev Get number of policies owned by an address
     */
    function getUserPolicyCount(address _user) external view returns (uint256) {
        return userPolicies[_user].length;
    }
    
    /**
     * @dev Check if a policy is active
     */
    function isPolicyActive(uint256 _policyId) external view returns (bool) {
        return policies[_policyId].isActive;
    }
    
    /**
     * @dev Verify policy ownership
     */
    function verifyOwnership(uint256 _policyId, address _owner) external view returns (bool) {
        return policies[_policyId].owner == _owner;
    }
    
    /**
     * @dev Deactivate a policy (admin only)
     */
    function deactivatePolicy(uint256 _policyId) external onlyAdmin {
        require(policies[_policyId].isActive, "Policy already inactive");
        policies[_policyId].isActive = false;
        emit PolicyDeactivated(_policyId, policies[_policyId].owner);
    }
    
    /**
     * @dev Withdraw contract balance (admin only)
     */
    function withdraw() external onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }
    
    /**
     * @dev Get contract balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
