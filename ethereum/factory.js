import web3 from './web3';
import CampaignFactory from './build/Factory.json';

const instance = new web3.eth.Contract(
  CampaignFactory.abi,
  '0xa3bfa1BEf16574B2FB08D587b125A20C670F2A62'
);

export default instance;
