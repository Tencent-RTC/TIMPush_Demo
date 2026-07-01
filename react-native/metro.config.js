const path = require('path');
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const useLocalTIMPush = process.env.TIM_PUSH_USE_SOURCE === '1' || process.env.TIM_PUSH_USE_SOURCE === 'true';
const localTIMPushRoot = path.resolve(__dirname, 'TIMPush');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * Default mode resolves @tencentcloud/react-native-push from npm package.
 * Set TIM_PUSH_USE_SOURCE=1 to debug the local TIMPush source folder.
 */
const config = useLocalTIMPush
  ? {
      watchFolders: [localTIMPushRoot],
      resolver: {
        extraNodeModules: {
          '@tencentcloud/react-native-push': localTIMPushRoot,
        },
        nodeModulesPaths: [path.resolve(__dirname, 'node_modules')],
      },
    }
  : {};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
