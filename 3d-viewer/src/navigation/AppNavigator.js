import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';

// Screens
import HomeScreen from '../screens/HomeScreen';
import ImageUploadScreen from '../screens/ImageUploadScreen';
import ProcessingScreen from '../screens/ProcessingScreen';
import Viewer3DScreen from '../screens/Viewer3DScreen';
import SettingsScreen from '../screens/SettingsScreen';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#2196F3',
        tabBarInactiveTintColor: '#999',
        headerShown: false,
      }}
    >
      <Tab.Screen 
        name="Home" 
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen 
        name="Upload" 
        component={ImageUploadScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="image" size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen 
        name="Settings" 
        component={SettingsScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="settings" size={size} color={color} />
          ),
        }}
      />
    </Tab.Navigator>
  );
}

export default function AppNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#2196F3',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}
    >
      <Stack.Screen 
        name="Main" 
        component={MainTabs}
        options={{ headerShown: false }}
      />
      <Stack.Screen 
        name="Processing" 
        component={ProcessingScreen}
        options={{ title: 'Processing Image' }}
      />
      <Stack.Screen 
        name="Viewer3D" 
        component={Viewer3DScreen}
        options={{ title: '3D Viewer', gestureEnabled: false }}
      />
    </Stack.Navigator>
  );
}
