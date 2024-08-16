const functions = require("firebase-functions");
const {RtcTokenBuilder} = require("agora-access-token");

const APP_ID = "64f97de078654dfca581ad1d4cbe42db";
const APP_CERTIFICATE = "887d3ef7aeb24f65a4054751eabe3d3c";

exports.generateAgoraToken = functions.https.onRequest((req, res) => {
  const {channelName, uid, role} = req.query;
  const expireTime = Math.floor(Date.now() / 1000) + 3600;

  const token = RtcTokenBuilder.buildTokenWithUid(APP_ID, APP_CERTIFICATE, channelName, uid, role, expireTime);
  res.json({token});
});
