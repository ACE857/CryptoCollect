const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledFactory = require('../ethereum/build/CampaingFactory.json');
const compiledCampaing = require('../ethereum/build/Campaing.json');

let accounts;
let factory;
let campaingAddress;
let campaing;

beforeEach( async () => {
    accounts = await web3.eth.getAccounts();

    factory = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
                .deploy( { data: compiledFactory.bytecode } )
                .send({ from: accounts[0], gas: '1000000' });

    await factory.methods.createCampaing('100').send({
      from: accounts[0],
      gas: '1000000'
    });

    [campaingAddress] = await factory.methods.getDeployedCampaings().call();
    campaing = await new web3.eth.Contract(
      JSON.parse(compiledCampaing.interface),
      campaingAddress
    );

} );

describe('Campaings', () => {
  it('deploys a factory and a campaing', () => {
    assert.ok(factory.options.address);
    assert.ok(campaing.options.address);
  });
});
