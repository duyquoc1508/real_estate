const RoleBasedAcl = artifacts.require("./RoleBasedAcl.sol");

require("chai")
  .use(require("chai-as-promised"))
  .should();

contract.skip("RoleBasedAcl", async accounts => {
  const [owner, notary, user1, user2] = [...accounts];

  let instance;
  before(async () => {
    instance = await RoleBasedAcl.new();
  });

  describe.skip("Deploy contract", async () => {
    it("Deployer should has role superadmin", async () => {
      const isSuperAdmin = await instance.hasRole(owner, "superadmin");
      assert.equal(isSuperAdmin, true);
    });
  });

  describe.skip("Add role", async () => {
    let result;
    it("Should add role successfully", async () => {
      result = await instance.addRole(user1, "notary", {from: owner});
      const isNotary = await instance.hasRole(user1, "notary");
      assert.equal(isNotary, true);
      const event = result.logs[0].args;
      assert.equal(event.account, user1);
      assert.equal(event.role, "notary");
    });
    it("Should be rejected, user not permissions", async () => {
      {
        // FAILURE: Superadmin is not granted other permissions
        await instance.addRole(owner, "notary", {from: owner}).should.be
          .rejected;
        // FAILURE: Method allowed only superadmin
        await instance.addRole(owner, "notary", {from: user1}).should.be
          .rejected;
      }
    });
  });

  describe.skip("Remove role", async () => {
    before(async () => {
      await instance.addRole(user2, "notary", {from: owner});
    });
    let result;
    it("Should remove role successfully", async () => {
      result = await instance.removeRole(user2, "notary", {from: owner});
      const isNotary = await instance.hasRole(user2, "notary");
      assert.equal(isNotary, false);
      const event = result.logs[0].args;
      assert.equal(event.account, user2);
      assert.equal(event.role, "notary");
    });
    it("Should be rejected", async () => {
      // FAILURE: Remove role account doesn't have role
      await instance.removeRole(owner, "notary", {from: owner}).should.be
        .rejected;
      // FAILURE: Method allowed only superadmin
      await instance.removeRole(owner, "superadmin", {from: user2}).should.be
        .rejected;
      // FAILURE: Unable remove role superadmin by itself
      await instance.removeRole(owner, "superadmin", {from: owner}).should.be
        .rejected;
    });
  });
});
