import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Switch,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import useAppStore from '../store/appStore';

const SettingsScreen = () => {
  const { settings, updateSettings, resetAll } = useAppStore();

  const handleReset = () => {
    Alert.alert(
      'Reset All Data',
      'This will clear all processed images and 3D models. This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Reset', 
          style: 'destructive',
          onPress: () => resetAll(),
        },
      ]
    );
  };

  const settingsGroups = [
    {
      title: 'Camera Settings',
      items: [
        {
          icon: 'camera',
          label: 'Camera Resolution',
          type: 'select',
          value: settings.cameraResolution,
          options: ['low', 'medium', 'high'],
          onChange: (value) => updateSettings({ cameraResolution: value }),
        },
      ],
    },
    {
      title: 'Processing Settings',
      items: [
        {
          icon: 'layers',
          label: 'Depth Model Quality',
          type: 'select',
          value: settings.depthModelQuality,
          options: ['low', 'medium', 'high'],
          onChange: (value) => updateSettings({ depthModelQuality: value }),
        },
        {
          icon: 'play',
          label: 'Auto Play',
          type: 'toggle',
          value: settings.autoPlay,
          onChange: (value) => updateSettings({ autoPlay: value }),
        },
      ],
    },
    {
      title: 'Head Tracking',
      items: [
        {
          icon: 'eye',
          label: 'Enable Head Tracking',
          type: 'toggle',
          value: settings.headTrackingEnabled,
          onChange: (value) => updateSettings({ headTrackingEnabled: value }),
        },
      ],
    },
    {
      title: 'Display',
      items: [
        {
          icon: 'speedometer',
          label: 'Show FPS',
          type: 'toggle',
          value: settings.showFPS,
          onChange: (value) => updateSettings({ showFPS: value }),
        },
      ],
    },
  ];

  const renderSettingItem = (item) => {
    if (item.type === 'toggle') {
      return (
        <TouchableOpacity 
          style={styles.settingItem}
          onPress={() => item.onChange(!item.value)}
        >
          <View style={styles.settingLeft}>
            <View style={styles.settingIcon}>
              <Ionicons name={item.icon} size={24} color="#2196F3" />
            </View>
            <Text style={styles.settingLabel}>{item.label}</Text>
          </View>
          <Switch
            value={item.value}
            onValueChange={item.onChange}
            trackColor={{ false: '#ccc', true: '#2196F3' }}
            thumbColor={item.value ? '#fff' : '#f4f3f4'}
          />
        </TouchableOpacity>
      );
    }

    if (item.type === 'select') {
      return (
        <View style={styles.settingItem}>
          <View style={styles.settingLeft}>
            <View style={styles.settingIcon}>
              <Ionicons name={item.icon} size={24} color="#2196F3" />
            </View>
            <Text style={styles.settingLabel}>{item.label}</Text>
          </View>
          <View style={styles.selectOptions}>
            {item.options.map((option) => (
              <TouchableOpacity
                key={option}
                style={[
                  styles.selectOption,
                  item.value === option && styles.selectOptionActive,
                ]}
                onPress={() => item.onChange(option)}
              >
                <Text
                  style={[
                    styles.selectOptionText,
                    item.value === option && styles.selectOptionTextActive,
                  ]}
                >
                  {option}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      );
    }

    return null;
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Settings</Text>
      
      <ScrollView style={styles.scrollView}>
        {settingsGroups.map((group, groupIndex) => (
          <View key={groupIndex} style={styles.group}>
            <Text style={styles.groupTitle}>{group.title}</Text>
            <View style={styles.groupContent}>
              {group.items.map((item, itemIndex) => (
                <View key={itemIndex}>
                  {renderSettingItem(item)}
                  {itemIndex < group.items.length - 1 && (
                    <View style={styles.divider} />
                  )}
                </View>
              ))}
            </View>
          </View>
        ))}

        {/* About Section */}
        <View style={styles.group}>
          <Text style={styles.groupTitle}>About</Text>
          <View style={styles.groupContent}>
            <View style={styles.aboutItem}>
              <View style={styles.settingLeft}>
                <View style={styles.settingIcon}>
                  <Ionicons name="information-circle" size={24} color="#2196F3" />
                </View>
                <View>
                  <Text style={styles.settingLabel}>3D Perspective Viewer</Text>
                  <Text style={styles.versionText}>Version 1.0.0</Text>
                </View>
              </View>
            </View>
          </View>
        </View>

        {/* Danger Zone */}
        <View style={styles.group}>
          <Text style={styles.groupTitleDanger}>Danger Zone</Text>
          <View style={styles.groupContent}>
            <TouchableOpacity style={styles.dangerButton} onPress={handleReset}>
              <Ionicons name="trash" size={24} color="#FF5252" />
              <Text style={styles.dangerButtonText}>Reset All Data</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    paddingTop: 50,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  scrollView: {
    flex: 1,
  },
  group: {
    marginBottom: 24,
    paddingHorizontal: 20,
  },
  groupTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#666',
    textTransform: 'uppercase',
    letterSpacing: 1,
    marginBottom: 12,
  },
  groupTitleDanger: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#FF5252',
    textTransform: 'uppercase',
    letterSpacing: 1,
    marginBottom: 12,
  },
  groupContent: {
    backgroundColor: 'white',
    borderRadius: 12,
    overflow: 'hidden',
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  settingIcon: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: '#E3F2FD',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  settingLabel: {
    fontSize: 16,
    color: '#333',
    fontWeight: '500',
  },
  selectOptions: {
    flexDirection: 'row',
    gap: 8,
  },
  selectOption: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    backgroundColor: '#fff',
  },
  selectOptionActive: {
    backgroundColor: '#2196F3',
    borderColor: '#2196F3',
  },
  selectOptionText: {
    fontSize: 14,
    color: '#666',
    textTransform: 'capitalize',
  },
  selectOptionTextActive: {
    color: 'white',
    fontWeight: '600',
  },
  divider: {
    height: 1,
    backgroundColor: '#E0E0E0',
    marginLeft: 72,
  },
  aboutItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
  },
  versionText: {
    fontSize: 14,
    color: '#999',
    marginTop: 4,
  },
  dangerButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    gap: 12,
  },
  dangerButtonText: {
    fontSize: 16,
    color: '#FF5252',
    fontWeight: '600',
  },
});

export default SettingsScreen;
