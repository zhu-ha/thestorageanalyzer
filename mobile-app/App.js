import React, { useState, useEffect, useRef } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Modal,
  Alert,
  Dimensions,
  StatusBar,
  RefreshControl,
  Animated,
  Platform
} from 'react-native';
import { StatusBar as ExpoStatusBar } from 'expo-status-bar';
import * as SecureStore from 'expo-secure-store';
import * as Network from 'expo-network';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

const { width, height } = Dimensions.get('window');

// Hyprland-style color scheme
const colors = {
  primary: '#1e1e2e',
  secondary: '#181825',
  surface: '#313244',
  surfaceAlt: '#45475a',
  textPrimary: '#cdd6f4',
  textSecondary: '#bac2de',
  textMuted: '#9399b2',
  accentBlue: '#89b4fa',
  accentGreen: '#a6e3a1',
  accentRed: '#f38ba8',
  accentYellow: '#f9e2af',
  accentOrange: '#fab387',
  archBlue: '#1793d1',
  success: '#a6e3a1',
  warning: '#f9e2af',
  error: '#f38ba8'
};

export default function App() {
  // State management
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [serverUrl, setServerUrl] = useState('');
  const [authToken, setAuthToken] = useState('');
  const [systemData, setSystemData] = useState({});
  const [isConnected, setIsConnected] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');

  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;

  // Load saved credentials on app start
  useEffect(() => {
    loadCredentials();
    animateIn();
  }, []);

  // Auto-refresh system data
  useEffect(() => {
    let interval;
    if (isAuthenticated && isConnected) {
      interval = setInterval(fetchSystemData, 5000);
    }
    return () => clearInterval(interval);
  }, [isAuthenticated, isConnected]);

  const animateIn = () => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 600,
        useNativeDriver: true,
      })
    ]).start();
  };

  const loadCredentials = async () => {
    try {
      const savedUrl = await SecureStore.getItemAsync('serverUrl');
      const savedToken = await SecureStore.getItemAsync('authToken');
      
      if (savedUrl && savedToken) {
        setServerUrl(savedUrl);
        setAuthToken(savedToken);
        await verifyConnection(savedUrl, savedToken);
      } else {
        setShowAuthModal(true);
      }
    } catch (error) {
      console.error('Error loading credentials:', error);
      setShowAuthModal(true);
    }
  };

  const saveCredentials = async (url, token) => {
    try {
      await SecureStore.setItemAsync('serverUrl', url);
      await SecureStore.setItemAsync('authToken', token);
    } catch (error) {
      console.error('Error saving credentials:', error);
    }
  };

  const verifyConnection = async (url, token) => {
    setIsLoading(true);
    setError('');

    try {
      const response = await fetch(`${url}/api/auth/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ token }),
      });

      const data = await response.json();

      if (data.valid) {
        setIsAuthenticated(true);
        setIsConnected(true);
        setShowAuthModal(false);
        await saveCredentials(url, token);
        await fetchSystemData();
      } else {
        throw new Error('Invalid authentication token');
      }
    } catch (error) {
      setError(error.message);
      setIsConnected(false);
      setIsAuthenticated(false);
    } finally {
      setIsLoading(false);
    }
  };

  const fetchSystemData = async () => {
    if (!isAuthenticated || !serverUrl || !authToken) return;

    try {
      const response = await fetch(`${serverUrl}/api/system`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();
      setSystemData(data);
      setIsConnected(true);
      setError('');
    } catch (error) {
      console.error('Error fetching system data:', error);
      setIsConnected(false);
      setError('Connection lost');
    }
  };

  const executePowerAction = async (action) => {
    Alert.alert(
      'Confirm Action',
      `Are you sure you want to ${action} the system?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Confirm',
          style: 'destructive',
          onPress: async () => {
            setIsLoading(true);
            try {
              const response = await fetch(`${serverUrl}/api/power/${action}`, {
                method: 'POST',
                headers: {
                  'Authorization': `Bearer ${authToken}`,
                  'Content-Type': 'application/json',
                },
              });

              const data = await response.json();

              if (data.success) {
                Alert.alert('Success', `${action} command sent successfully`);
              } else {
                throw new Error(data.error || 'Unknown error');
              }
            } catch (error) {
              Alert.alert('Error', `Failed to ${action}: ${error.message}`);
            } finally {
              setIsLoading(false);
            }
          },
        },
      ]
    );
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchSystemData();
    setRefreshing(false);
  };

  const handleConnect = () => {
    if (!serverUrl.trim() || !authToken.trim()) {
      setError('Please enter both server URL and auth token');
      return;
    }
    verifyConnection(serverUrl.trim(), authToken.trim());
  };

  const formatBytes = (bytes, unit = 'GB') => {
    if (!bytes) return '0';
    const value = unit === 'GB' ? bytes / (1024 ** 3) : bytes / (1024 ** 2);
    return value.toFixed(1);
  };

  const CircularProgress = ({ percentage, size = 80, color = colors.accentBlue }) => {
    const radius = (size - 10) / 2;
    const circumference = 2 * Math.PI * radius;
    const strokeDashoffset = circumference - (percentage / 100) * circumference;

    return (
      <View style={{ width: size, height: size, position: 'relative' }}>
        <View style={[styles.progressContainer, { width: size, height: size }]}>
          <View style={styles.progressBackground} />
          <View 
            style={[
              styles.progressForeground, 
              { 
                transform: [{ rotate: `${(percentage / 100) * 360}deg` }],
                borderTopColor: color 
              }
            ]} 
          />
          <View style={styles.progressCenter}>
            <Text style={styles.progressText}>{Math.round(percentage)}%</Text>
          </View>
        </View>
      </View>
    );
  };

  const PowerButton = ({ icon, title, action, color }) => (
    <TouchableOpacity
      style={[styles.powerButton, { borderColor: color }]}
      onPress={() => executePowerAction(action)}
    >
      <Ionicons name={icon} size={32} color={color} />
      <Text style={[styles.powerButtonText, { color }]}>{title}</Text>
    </TouchableOpacity>
  );

     const StatCard = ({ icon, title, value, subtitle, progress, color, extra }) => (
     <View style={styles.statCard}>
       <View style={styles.statHeader}>
         <Ionicons name={icon} size={24} color={color} />
         <Text style={styles.statTitle}>{title}</Text>
       </View>
       <View style={styles.statContent}>
         <CircularProgress percentage={progress || 0} color={color} />
         <View style={styles.statDetails}>
           <Text style={styles.statValue}>{value}</Text>
           <Text style={styles.statSubtitle}>{subtitle}</Text>
           {extra && <Text style={styles.statExtra}>{extra}</Text>}
         </View>
       </View>
     </View>
   );

  if (!isAuthenticated) {
    return (
      <LinearGradient colors={[colors.primary, colors.secondary]} style={styles.container}>
        <ExpoStatusBar style="light" />
        <StatusBar backgroundColor={colors.primary} barStyle="light-content" />
        
        <Animated.View 
          style={[
            styles.authContainer,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }]
            }
          ]}
        >
          <View style={styles.authCard}>
            <View style={styles.authHeader}>
              <Ionicons name="server" size={48} color={colors.archBlue} />
              <Text style={styles.authTitle}>Power Control</Text>
              <Text style={styles.authSubtitle}>Connect to your Arch Linux system</Text>
            </View>

            <View style={styles.authForm}>
              <Text style={styles.inputLabel}>Server URL</Text>
              <TextInput
                style={styles.textInput}
                placeholder="http://192.168.1.100:8888"
                placeholderTextColor={colors.textMuted}
                value={serverUrl}
                onChangeText={setServerUrl}
                autoCapitalize="none"
                autoCorrect={false}
              />

              <Text style={styles.inputLabel}>Authentication Token</Text>
              <TextInput
                style={styles.textInput}
                placeholder="Enter auth token"
                placeholderTextColor={colors.textMuted}
                value={authToken}
                onChangeText={setAuthToken}
                secureTextEntry
                autoCapitalize="none"
                autoCorrect={false}
              />

              {error ? (
                <Text style={styles.errorText}>{error}</Text>
              ) : null}

              <TouchableOpacity
                style={[styles.connectButton, isLoading && styles.connectButtonDisabled]}
                onPress={handleConnect}
                disabled={isLoading}
              >
                <Text style={styles.connectButtonText}>
                  {isLoading ? 'Connecting...' : 'Connect'}
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </Animated.View>
      </LinearGradient>
    );
  }

  return (
    <LinearGradient colors={[colors.primary, colors.secondary]} style={styles.container}>
      <ExpoStatusBar style="light" />
      <StatusBar backgroundColor={colors.primary} barStyle="light-content" />
      
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerContent}>
          <View>
            <Text style={styles.headerTitle}>{systemData.hostname || 'Arch System'}</Text>
            <Text style={styles.headerSubtitle}>Power Control Dashboard</Text>
          </View>
          <View style={styles.connectionStatus}>
            <View style={[styles.statusDot, { backgroundColor: isConnected ? colors.success : colors.error }]} />
            <Text style={styles.statusText}>{isConnected ? 'Connected' : 'Disconnected'}</Text>
          </View>
        </View>
      </View>

      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.accentBlue} />
        }
      >
                 {/* System Stats */}
         <View style={styles.section}>
           <Text style={styles.sectionTitle}>System Monitor</Text>
           <View style={styles.statsGrid}>
             <StatCard
               icon="hardware-chip"
               title="CPU"
               value={`${Math.round(systemData.cpu?.usage_percent || 0)}%`}
               subtitle={`${systemData.cpu?.count || 0} cores • ${Math.round((systemData.cpu?.frequency?.current || 0) / 1000)} MHz`}
               progress={systemData.cpu?.usage_percent || 0}
               color={colors.accentBlue}
               extra={systemData.cpu?.load_avg ? `Load: ${systemData.cpu.load_avg['1min']?.toFixed(2)}` : null}
             />
             <StatCard
               icon="server"
               title="Memory"
               value={`${formatBytes(systemData.memory?.used)} GB`}
               subtitle={`of ${formatBytes(systemData.memory?.total)} GB total`}
               progress={systemData.memory?.percent || 0}
               color={colors.accentGreen}
               extra={`Available: ${formatBytes(systemData.memory?.available)} GB`}
             />
             <StatCard
               icon="folder"
               title="Storage"
               value={`${formatBytes(systemData.disk?.used)} GB`}
               subtitle={`${formatBytes(systemData.disk?.free)} GB free`}
               progress={systemData.disk?.percent || 0}
               color={colors.accentOrange}
               extra={`Total: ${formatBytes(systemData.disk?.total)} GB`}
             />
           </View>
         </View>

        {/* Battery & Temperature */}
        {(systemData.battery?.percent !== null || systemData.temperature) && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Hardware Status</Text>
            <View style={styles.hardwareGrid}>
              {systemData.battery?.percent !== null && (
                <View style={styles.hardwareCard}>
                  <Ionicons 
                    name={systemData.battery.power_plugged ? "battery-charging" : "battery-half"} 
                    size={24} 
                    color={colors.accentYellow} 
                  />
                  <Text style={styles.hardwareTitle}>Battery</Text>
                  <Text style={styles.hardwareValue}>{Math.round(systemData.battery.percent)}%</Text>
                  <Text style={styles.hardwareSubtitle}>
                    {systemData.battery.power_plugged ? 'Charging' : 'On Battery'}
                  </Text>
                </View>
              )}
              
              {systemData.temperature && Object.keys(systemData.temperature).length > 0 && (
                <View style={styles.hardwareCard}>
                  <Ionicons name="thermometer" size={24} color={colors.accentRed} />
                  <Text style={styles.hardwareTitle}>Temperature</Text>
                  <Text style={styles.hardwareValue}>
                    {Math.round(Math.max(...Object.values(systemData.temperature).map(t => t.current || 0)))}°C
                  </Text>
                  <Text style={styles.hardwareSubtitle}>CPU Temperature</Text>
                </View>
              )}
            </View>
          </View>
        )}

        {/* Power Control */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Power Control</Text>
          <View style={styles.powerGrid}>
            <PowerButton
              icon="power"
              title="Shutdown"
              action="shutdown"
              color={colors.accentRed}
            />
            <PowerButton
              icon="refresh"
              title="Reboot"
              action="reboot"
              color={colors.accentYellow}
            />
            <PowerButton
              icon="moon"
              title="Suspend"
              action="suspend"
              color={colors.accentBlue}
            />
            <PowerButton
              icon="snow"
              title="Hibernate"
              action="hibernate"
              color={colors.textMuted}
            />
          </View>
        </View>

                 {/* Running Processes */}
         {systemData.processes && systemData.processes.length > 0 && (
           <View style={styles.section}>
             <Text style={styles.sectionTitle}>Running Processes</Text>
             <View style={styles.processCard}>
               <View style={styles.processHeader}>
                 <Text style={styles.processHeaderText}>Process</Text>
                 <Text style={styles.processHeaderText}>CPU%</Text>
                 <Text style={styles.processHeaderText}>RAM%</Text>
               </View>
               {systemData.processes.slice(0, 8).map((process, index) => (
                 <View key={index} style={styles.processRow}>
                   <Text style={styles.processName} numberOfLines={1}>
                     {process.name || 'Unknown'}
                   </Text>
                   <Text style={styles.processCpu}>
                     {(process.cpu_percent || 0).toFixed(1)}%
                   </Text>
                   <Text style={styles.processMemory}>
                     {(process.memory_percent || 0).toFixed(1)}%
                   </Text>
                 </View>
               ))}
               <TouchableOpacity 
                 style={styles.viewAllProcesses}
                 onPress={() => Alert.alert(
                   'All Processes',
                   systemData.processes.slice(0, 15).map(p => 
                     `${p.name}: CPU ${(p.cpu_percent || 0).toFixed(1)}%, RAM ${(p.memory_percent || 0).toFixed(1)}%`
                   ).join('\n'),
                   [{ text: 'OK' }]
                 )}
               >
                 <Text style={styles.viewAllText}>View All ({systemData.processes.length} total)</Text>
               </TouchableOpacity>
             </View>
           </View>
         )}

         {/* System Info */}
         <View style={styles.section}>
           <Text style={styles.sectionTitle}>System Information</Text>
           <View style={styles.infoCard}>
             <View style={styles.infoRow}>
               <Text style={styles.infoLabel}>Uptime</Text>
               <Text style={styles.infoValue}>{systemData.uptime?.formatted || '--'}</Text>
             </View>
             <View style={styles.infoRow}>
               <Text style={styles.infoLabel}>Kernel</Text>
               <Text style={styles.infoValue}>{systemData.kernel || '--'}</Text>
             </View>
             <View style={styles.infoRow}>
               <Text style={styles.infoLabel}>Desktop</Text>
               <Text style={styles.infoValue}>{systemData.desktop?.session || '--'}</Text>
             </View>
             <View style={styles.infoRow}>
               <Text style={styles.infoLabel}>Session</Text>
               <Text style={styles.infoValue}>{systemData.desktop?.session_type || '--'}</Text>
             </View>
             <View style={styles.infoRow}>
               <Text style={styles.infoLabel}>Architecture</Text>
               <Text style={styles.infoValue}>{systemData.arch || '--'}</Text>
             </View>
             <View style={styles.infoRow}>
               <Text style={styles.infoLabel}>Network Sent</Text>
               <Text style={styles.infoValue}>{formatBytes(systemData.network?.bytes_sent, 'MB')} MB</Text>
             </View>
             <View style={styles.infoRow}>
               <Text style={styles.infoLabel}>Network Received</Text>
               <Text style={styles.infoValue}>{formatBytes(systemData.network?.bytes_recv, 'MB')} MB</Text>
             </View>
           </View>
         </View>

        <View style={{ height: 50 }} />
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  authContainer: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  authCard: {
    backgroundColor: colors.surface,
    borderRadius: 20,
    padding: 30,
    alignItems: 'center',
  },
  authHeader: {
    alignItems: 'center',
    marginBottom: 30,
  },
  authTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: colors.textPrimary,
    marginTop: 15,
  },
  authSubtitle: {
    fontSize: 16,
    color: colors.textSecondary,
    marginTop: 5,
    textAlign: 'center',
  },
  authForm: {
    width: '100%',
  },
  inputLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textSecondary,
    marginBottom: 8,
    marginTop: 15,
  },
  textInput: {
    backgroundColor: colors.secondary,
    borderRadius: 12,
    padding: 15,
    fontSize: 16,
    color: colors.textPrimary,
    borderWidth: 1,
    borderColor: colors.surfaceAlt,
  },
  errorText: {
    color: colors.error,
    fontSize: 14,
    marginTop: 10,
    textAlign: 'center',
  },
  connectButton: {
    backgroundColor: colors.archBlue,
    borderRadius: 12,
    padding: 18,
    marginTop: 25,
    alignItems: 'center',
  },
  connectButtonDisabled: {
    opacity: 0.5,
  },
  connectButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: Platform.OS === 'ios' ? 50 : 20,
    paddingBottom: 20,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: colors.textPrimary,
  },
  headerSubtitle: {
    fontSize: 14,
    color: colors.textSecondary,
    marginTop: 2,
  },
  connectionStatus: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  statusText: {
    fontSize: 12,
    color: colors.textSecondary,
  },
  scrollView: {
    flex: 1,
  },
  section: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.textPrimary,
    marginBottom: 15,
  },
  statsGrid: {
    gap: 15,
  },
  statCard: {
    backgroundColor: colors.surface,
    borderRadius: 15,
    padding: 20,
    marginBottom: 10,
  },
  statHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  statTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.textPrimary,
    marginLeft: 10,
  },
  statContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statDetails: {
    marginLeft: 20,
    flex: 1,
  },
  statValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.textPrimary,
  },
  statSubtitle: {
    fontSize: 14,
    color: colors.textSecondary,
    marginTop: 2,
  },
  progressContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  progressBackground: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    borderRadius: 40,
    borderWidth: 6,
    borderColor: colors.secondary,
  },
  progressForeground: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    borderRadius: 40,
    borderWidth: 6,
    borderColor: 'transparent',
    borderTopWidth: 6,
  },
  progressCenter: {
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
  },
  progressText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: colors.textPrimary,
  },
  hardwareGrid: {
    flexDirection: 'row',
    gap: 15,
  },
  hardwareCard: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: 15,
    padding: 20,
    alignItems: 'center',
  },
  hardwareTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textSecondary,
    marginTop: 10,
  },
  hardwareValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.textPrimary,
    marginTop: 5,
  },
  hardwareSubtitle: {
    fontSize: 12,
    color: colors.textMuted,
    marginTop: 2,
    textAlign: 'center',
  },
  powerGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 15,
  },
  powerButton: {
    flex: 1,
    minWidth: (width - 60) / 2 - 7.5,
    backgroundColor: colors.surface,
    borderRadius: 15,
    padding: 20,
    alignItems: 'center',
    borderWidth: 2,
  },
  powerButtonText: {
    fontSize: 14,
    fontWeight: '600',
    marginTop: 10,
    textTransform: 'uppercase',
  },
  infoCard: {
    backgroundColor: colors.surface,
    borderRadius: 15,
    padding: 20,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceAlt,
  },
  infoLabel: {
    fontSize: 14,
    color: colors.textSecondary,
    fontWeight: '500',
  },
  infoValue: {
    fontSize: 14,
    color: colors.textPrimary,
    fontWeight: '600',
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  statExtra: {
    fontSize: 11,
    color: colors.textMuted,
    marginTop: 2,
  },
  processCard: {
    backgroundColor: colors.surface,
    borderRadius: 15,
    padding: 16,
    borderWidth: 1,
    borderColor: colors.surfaceAlt,
  },
  processHeader: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: colors.surfaceAlt,
    paddingBottom: 8,
    marginBottom: 8,
  },
  processHeaderText: {
    fontSize: 12,
    color: colors.accentBlue,
    fontWeight: 'bold',
    flex: 1,
    textAlign: 'center',
  },
  processRow: {
    flexDirection: 'row',
    paddingVertical: 6,
    alignItems: 'center',
  },
  processName: {
    fontSize: 12,
    color: colors.textPrimary,
    flex: 2,
    marginRight: 8,
  },
  processCpu: {
    fontSize: 11,
    color: colors.accentOrange,
    textAlign: 'center',
    flex: 1,
    fontWeight: 'bold',
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  processMemory: {
    fontSize: 11,
    color: colors.accentGreen,
    textAlign: 'center',
    flex: 1,
    fontWeight: 'bold',
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  viewAllProcesses: {
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: colors.surfaceAlt,
    alignItems: 'center',
  },
  viewAllText: {
    fontSize: 11,
    color: colors.accentBlue,
    fontWeight: 'bold',
  },
});