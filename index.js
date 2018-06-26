import {NativeModules} from 'react-native';

var RNLocalNotifications = {
  requestAuthorization: function() {
        return NativeModules.RNLocalNotifications.requestAuthorization()
  },
  createNotification: function(id, text, datetime, sound, hiddendata='', repeatInterval) {
        NativeModules.RNLocalNotifications.createNotification(id, text, datetime, sound, hiddendata, repeatInterval);
  },
  deleteNotification: function(id) {
        NativeModules.RNLocalNotifications.deleteNotification(id);
  },
  updateNotification: function(id, text, datetime, sound, hiddendata='', repeatInterval) {
        NativeModules.RNLocalNotifications.updateNotification(id, text, datetime, sound, hiddendata, repeatInterval);
  },
  setAndroidIcons: function(largeIconName, largeIconType, smallIconName, smallIconType) {
        NativeModules.RNLocalNotifications.setAndroidIcons(largeIconName, largeIconType, smallIconName, smallIconType);
  },
};

export default RNLocalNotifications;
