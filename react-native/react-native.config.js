const path = require('path');

const useLocalTIMPush = process.env.TIM_PUSH_USE_SOURCE === '1' || process.env.TIM_PUSH_USE_SOURCE === 'true';
const localTIMPushRoot = path.resolve(__dirname, 'TIMPush');

module.exports = useLocalTIMPush
  ? {
      dependencies: {
        '@tencentcloud/react-native-push': {
          root: localTIMPushRoot,
        },
      },
    }
  : {};
