import { useRef, useState } from 'react';
import { Linking, Pressable, StyleSheet, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { WebView } from 'react-native-webview';

// The iOS app is the learner web app (frontend/) in a full-screen WebView,
// so every web deploy to Netlify reaches the app without a new build.
const APP_URL = 'https://dienham.netlify.app';

const PINK = '#EC5B8D';
const BLUSH = '#FDE4EE';

function isInternal(url) {
  return url === APP_URL || url.startsWith(APP_URL + '/') || /^(about|blob|data):/.test(url);
}

export default function App() {
  const web = useRef(null);
  const [key, setKey] = useState(0); // bump to rebuild the WebView after an error

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
        <StatusBar style="dark" />
        <WebView
          key={key}
          ref={web}
          source={{ uri: APP_URL }}
          style={styles.root}
          // Lets the web app know it runs inside the app (hides the "install the app" banner).
          applicationNameForUserAgent="StudyForYouApp"
          // Microphone for pronunciation practice and recording; asked once by iOS.
          mediaCapturePermissionGrantType="grantIfSameHostElsePrompt"
          allowsInlineMediaPlayback
          mediaPlaybackRequiresUserAction={false}
          allowsBackForwardNavigationGestures
          bounces={false}
          // Other sites (the admin page, links in documents) open in Safari.
          onShouldStartLoadWithRequest={(req) => {
            if (isInternal(req.url)) return true;
            Linking.openURL(req.url);
            return false;
          }}
          onOpenWindow={(e) => Linking.openURL(e.nativeEvent.targetUrl)}
          // iOS may kill the web process in the background; reload instead of a blank screen.
          onContentProcessDidTerminate={() => web.current?.reload()}
          startInLoadingState
          renderLoading={() => (
            <View style={styles.center}>
              <Text style={styles.title}>Study For You 💕</Text>
              <Text style={styles.muted}>Đang tải...</Text>
            </View>
          )}
          renderError={() => (
            <View style={styles.center}>
              <Text style={styles.title}>Không kết nối được 😢</Text>
              <Text style={styles.muted}>Kiểm tra mạng rồi thử lại nhé</Text>
              <Pressable style={styles.button} onPress={() => setKey((k) => k + 1)}>
                <Text style={styles.buttonText}>Thử lại</Text>
              </Pressable>
            </View>
          )}
        />
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: BLUSH },
  center: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: BLUSH,
    padding: 24,
  },
  title: { fontSize: 22, fontWeight: '800', color: PINK, marginBottom: 8 },
  muted: { fontSize: 15, color: '#9A8790' },
  button: {
    marginTop: 20,
    backgroundColor: PINK,
    paddingHorizontal: 28,
    paddingVertical: 12,
    borderRadius: 24,
  },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '700' },
});
