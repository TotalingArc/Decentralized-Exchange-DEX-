const Link = artifacts.require("Link");
const Dex = artifacts.require("Dex")

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Link);
  

}

// Let Migration handle migration by removing the testing file in  token_migration.js