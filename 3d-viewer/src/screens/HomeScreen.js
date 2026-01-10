import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Image,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import useAppStore from '../store/appStore';

const HomeScreen = () => {
  const navigation = useNavigation();
  const { selectedImage, processed3DModel } = useAppStore();

  const features = [
    {
      icon: 'camera',
      title: 'Camera Capture',
      description: 'Capture photos in real-time',
      color: '#2196F3',
    },
    {
      icon: 'images',
      title: 'Gallery Upload',
      description: 'Select from device gallery',
      color: '#4CAF50',
    },
    {
      icon: 'cube',
      title: '3D Conversion',
      description: 'AI-powered depth estimation',
      color: '#FF9800',
    },
    {
      icon: 'eye',
      title: 'Head Tracking',
      description: 'Real-time perspective control',
      color: '#9C27B0',
    },
  ];

  const handleContinueToViewer = () => {
    if (processed3DModel) {
      navigation.navigate('Viewer3D');
    } else if (selectedImage) {
      navigation.navigate('Processing');
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>3D Perspective Viewer</Text>
        <Text style={styles.subtitle}>
          Transform images into immersive 3D experiences with head tracking
        </Text>
      </View>

      {/* Recent Project Card */}
      {selectedImage && (
        <TouchableOpacity
          style={styles.recentProjectCard}
          onPress={handleContinueToViewer}
        >
          <Image source={{ uri: selectedImage.uri }} style={styles.recentImage} />
          <View style={styles.recentInfo}>
            <Text style={styles.recentTitle}>
              {processed3DModel ? 'Continue Viewing' : 'Complete Processing'}
            </Text>
            <Text style={styles.recentSubtitle}>
              {processed3DModel 
                ? '3D model ready with head tracking' 
                : 'Image selected - ready for 3D conversion'}
            </Text>
            <View style={styles.statusBadge}>
              <Ionicons 
                name={processed3DModel ? "cube" : "hourglass"} 
                size={16} 
                color="white" 
              />
              <Text style={styles.statusText}>
                {processed3DModel ? 'Ready' : 'Processing'}
              </Text>
            </View>
          </View>
        </TouchableOpacity>
      )}

      {/* Quick Actions */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Quick Actions</Text>
        
        <TouchableOpacity
          style={[styles.actionCard, { backgroundColor: '#2196F3' }]}
          onPress={() => navigation.navigate('Upload', { mode: 'camera' })}
        >
          <Ionicons name="camera" size={32} color="white" />
          <Text style={styles.actionTitle}>Take Photo</Text>
          <Text style={styles.actionSubtitle}>Capture with camera</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.actionCard, { backgroundColor: '#4CAF50' }]}
          onPress={() => navigation.navigate('Upload', { mode: 'gallery' })}
        >
          <Ionicons name="images" size={32} color="white" />
          <Text style={styles.actionTitle}>Upload from Gallery</Text>
          <Text style={styles.actionSubtitle}>Select from device</Text>
        </TouchableOpacity>
      </View>

      {/* Features */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Features</Text>
        {features.map((feature, index) => (
          <View key={index} style={styles.featureCard}>
            <View style={[styles.featureIcon, { backgroundColor: feature.color }]}>
              <Ionicons name={feature.icon} size={24} color="white" />
            </View>
            <View style={styles.featureInfo}>
              <Text style={styles.featureTitle}>{feature.title}</Text>
              <Text style={styles.featureDescription}>{feature.description}</Text>
            </View>
          </View>
        ))}
      </View>

      {/* Info Section */}
      <View style={styles.infoCard}>
        <Ionicons name="information-circle" size={24} color="#2196F3" />
        <Text style={styles.infoText}>
          This app uses AI depth estimation to convert 2D images into 3D models. 
          Head tracking allows you to view the 3D model from different perspectives by moving your head.
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: 24,
    backgroundColor: '#2196F3',
    borderBottomLeftRadius: 24,
    borderBottomRightRadius: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.9)',
    lineHeight: 20,
  },
  section: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 16,
  },
  recentProjectCard: {
    margin: 20,
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 16,
    flexDirection: 'row',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  recentImage: {
    width: 80,
    height: 80,
    borderRadius: 12,
  },
  recentInfo: {
    flex: 1,
    marginLeft: 16,
    justifyContent: 'center',
  },
  recentTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  recentSubtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2196F3',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    alignSelf: 'flex-start',
  },
  statusText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
    marginLeft: 4,
  },
  actionCard: {
    borderRadius: 16,
    padding: 24,
    marginBottom: 16,
    alignItems: 'center',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  actionTitle: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    marginTop: 12,
  },
  actionSubtitle: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 14,
    marginTop: 4,
  },
  featureCard: {
    flexDirection: 'row',
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  featureIcon: {
    width: 50,
    height: 50,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  featureInfo: {
    flex: 1,
    justifyContent: 'center',
    marginLeft: 12,
  },
  featureTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  featureDescription: {
    fontSize: 14,
    color: '#666',
  },
  infoCard: {
    margin: 20,
    backgroundColor: '#E3F2FD',
    padding: 16,
    borderRadius: 12,
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  infoText: {
    flex: 1,
    fontSize: 13,
    color: '#1565C0',
    marginLeft: 12,
    lineHeight: 18,
  },
});

export default HomeScreen;
