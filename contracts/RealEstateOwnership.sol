pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "./RealEstate.sol";


contract RealEstateOwnership is RealEstate {
	/// @dev This emits when ownership of any NFTs changes by any mechanism
	event Transfer(
		address[] _oldOwner,
		address[] _newOwner,
		uint256 _tokenId,
		address indexed _notary
	);

	/**
	 * @notice Find the owner of a NFTs
	 * @dev NFTs assigned to zero address are considered invalid, and queries about them do throw
	 * @param _tokenId The identifier of the NFTs
	 * @return The address of the owner of the NFTs
	 */
	function ownerOf(uint256 _tokenId) external view returns (address[] memory) {
		return getAllOwners(_tokenId);
	}

	/**
	 * @notice Transfer ownership of certificate
	 * @dev Only notary allowed
	 */
	function transfer(address[] calldata _newOwners, uint256 _id)
		external
		onlySelling(_id) // require state of certificate is 'Selling'
		onlyRole("notary") // require msg.sender is notary
	{
		require(_newOwners.length > 0, "RealEstateOwnership: Require one owner at least");
		address[] memory _currentOwners = getAllOwners(_id);
		tokenToOwners[_id] = _newOwners;
		tokenToState[_id] = State.Activated;
		delete tokenToApprovals[_id];
		emit Transfer(_currentOwners, _newOwners, _id, msg.sender);
	}
}
