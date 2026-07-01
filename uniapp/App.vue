<script>
import { setRegistrationID, registerPush, getRegistrationID, EVENT, addPushListener } from '@/uni_modules/TencentCloud-Push';

setRegistrationID('9246', () => {
	console.log('App.vue | setRegistrationID ok');
});

registerPush(0, '', (data) => {
		console.log('App.vue | registerPush ok', data);
		getRegistrationID((registrationID) => {
			console.log('App.vue | getRegistrationID ok', registrationID);
		});
	}, (errCode, errMsg) => {
		console.error('App.vue | registerPush failed', errCode, errMsg);
	}
);

const onNotificationClicked = (res) => {
	console.log('App.vue | onNotificationClicked', res);
}
addPushListener(EVENT.NOTIFICATION_CLICKED, onNotificationClicked);

// 监听在线新消息
const onMessageReceived = (res) => {
	console.log('App.vue | onMessageReceived', res, JSON.stringify(res));
}
addPushListener(EVENT.MESSAGE_RECEIVED, onMessageReceived);
// 监听在线撤回消息
const onMessageRevoked = (res) => {
	console.log('App.vue | onMessageRevoked', res);
}
addPushListener(EVENT.MESSAGE_REVOKED, onMessageRevoked);

export default {
    onLaunch: function() {
		
    },
    onShow: function() {
        console.log('App Show')
    },
    onHide: function() {
        console.log('App Hide')
    }
}
</script>

<style>
    /*每个页面公共css */
</style>
