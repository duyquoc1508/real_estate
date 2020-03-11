const RealEstate = artifacts.require("./RealEstate.sol");

require("chai")
  .use(require("chai-as-promised"))
  .should();

contract("RealEstate", accounts => {
  const [deployer, notary, owner1, owner2, otherUser] = [...accounts];
  let realEstate;

  before(async () => {
    realEstate = await RealEstate.new();
  });

  describe.skip("deployment", async () => {
    it("deploys successfully", async () => {
      const address = await realEstate.address;
      assert.notEqual(address, 0x0);
      assert.notEqual(address, "");
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    });
    it("has a name", async () => {
      const name = await realEstate.name();
      assert.equal(name, "Dapp Real Estate");
    });
  });

  describe("Certificate", async () => {
    let result, idCertificate, tokenToOwners, tokenToState, tokenToNotary;
    before(async () => {
      result = await realEstate.createCertificate(
        [
          "address",
          "purpose of use",
          "time of use",
          "origin of use",
          20,
          20,
          200
        ],
        [
          4,
          200,
          "address",
          "house type",
          "appartment name",
          "floor area",
          "form of own",
          "time of use"
        ],
        "orther construction",
        "prod forest is artificial forest",
        "perennial tree",
        "notice",
        // [
        //   "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C",
        //   "0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB"
        // ],
        [owner1, owner2],
        {from: notary}
      );
      // current certificate id
      idCertificate = await realEstate.certificateCount();
      tokenToNotary = await realEstate.tokenToNotary(idCertificate);
      tokenToState = await realEstate.tokenToState(idCertificate);
      tokenToOwners = await realEstate.getAllOwners(idCertificate);
    });
    it("Create certificate", async () => {
      assert.equal(idCertificate, 1);
      assert.equal(tokenToNotary, notary);
      // token state is 'pendding': 0
      assert.equal(tokenToState.toNumber(), 0);
      const event = result.logs[0].args;
      assert.equal(event.notary, notary, "notary is correct");
      assert.equal(tokenToOwners.length, 2);
    });
  });

  describe("Activate", async () => {
    let tokenToState, tokenToApprove, tokenToOwners;
    before(async () => {
      tokenToOwners = await realEstate.getAllOwners(idCertificate);
      tokenToState = await realEstate.tokenToState(idCertificate);
      tokenToApprove = await realEstate.getAllApproved(idCertificate);
    });
    // require owner of certificate
    const idCertificate = 1;

    it("Activate successfully", async () => {
      assert.equal(tokenToState.toNumber(), 0);
      assert.equal(tokenToApprove.length, 0);
      const tx = [
        await realEstate.activate(idCertificate, {from: owner1}), // 1 event
        await realEstate.activate(idCertificate, {from: owner2}) // 2 event
      ];
      tokenToState = await realEstate.tokenToState(idCertificate);
      assert.equal(tokenToState.toNumber(), 1);
      const logs = tx.map(item => item.logs).flat(); // [ev1,[ev1, ev2]] => [ev1,ev1,ev2]
      assert.equal(logs[2].event, "Activated");
    });

    it("is owner", async () => {
      await realEstate.activate(idCertificate, {from: otherUser}).should.be
        .rejected;
      await realEstate.activate(idCertificate, {from: notary}).should.be
        .rejected;
    });
  });

  describe("Transfer", async () => {
    before(async () => {
      await realEstate.transfer([owner1, owner2], otherUser, 1, {from: notary});
    });
  });
});
