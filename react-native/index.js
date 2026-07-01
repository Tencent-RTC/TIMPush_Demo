/**
 * @format
 */

import {AppRegistry} from 'react-native';
import Push from '@tencentcloud/react-native-push';
import App from './App';
import {name as appName} from './app.json';

export const registerPushForDemo = (sdkAppId, appKey, onSuccess, onError) => {
  Push.registerPush(sdkAppId, appKey, onSuccess, onError);
};

AppRegistry.registerComponent(appName, () => App);
