pragma solidity >=0.4.21 <0.7.0;


/**
 * @title RoleBasedAcl (Roles-based access control)
 * @dev Contract managing addressed role based access control
 */

contract RoleBasedAcl {
	mapping(address => mapping(string => bool)) roles;

	event RoleAdded(address indexed account, string role);
	event RoleRemoved(address indexed account, string role);

	constructor() public {
		roles[msg.sender]["superadmin"] = true;
	}

	/**
	 * @dev add a role to an address (ignore superadmin)
	 * @param _account address
	 * @param _role the name of the role
	 */
	function addRole(address _account, string memory _role) public onlyRole("superadmin") {
		require(_account != msg.sender, "Roles: Superadmin don't have any other roles");
		require(!hasRole(_account, _role), "Roles: account already has role");
		roles[_account][_role] = true;
		emit RoleAdded(_account, _role);
	}

	/**
	 * @dev remove a role from an address
	 * @param _account address
	 * @param _role the name of the role
	 */
	function removeRole(address _account, string memory _role) public onlyRole("superadmin") {
		require(_account != msg.sender, "Roles: Unable to remove superadmin role itself");
		require(hasRole(_account, _role), "Roles: Account doesn't have role");
		roles[_account][_role] = false;
		emit RoleRemoved(_account, _role);
	}

	/**
	 * @dev determine if addr has role
	 * @param _account address
	 * @param _role the name of the role
	 * @return bool
	 */
	function hasRole(address _account, string memory _role) public view returns (bool) {
		require(_account != address(0), "Roles: account is the zero address");
		return roles[_account][_role];
	}

	// /**
	//  * @dev reverts if addr does not have role
	//  * @param _account address
	//  * @param _role the name of the role
	//  */
	// function checkRole(address _account, string memory _role) public view {
	// 	require(hasRole(_account, _role), "Roles: Account does not have role");
	// }

	/**
	 * @dev modifier to scope access to a single role (uses msg.sender as addr)
	 * @param _role the name of the role
	 */
	modifier onlyRole(string memory _role) {
		require(hasRole(msg.sender, _role), "Roles: Account does not permission");
		_;
	}
}
