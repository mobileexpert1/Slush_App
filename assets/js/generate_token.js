const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

const appID = 'ace5073becd844af9e3a1651abf1b1ef';
const appCertificate = '43fb710dde43428e9dfc8fc933a55f16';
const channelName = 'YOUR_CHANNEL_NAME';
const uid = 0; // 0 means the token is for a user with any UID
const role = RtcRole.PUBLISHER;
const expirationTimeInSeconds = 3600;

const currentTimestamp = Math.floor(Date.now() / 1000);
const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

const token = RtcTokenBuilder.buildTokenWithUid(appID, appCertificate, channelName, uid, role, privilegeExpiredTs);
console.log('Token:', token);