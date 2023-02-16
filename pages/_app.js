import { ThemeProvider } from 'next-themes';
import Script from 'next/script';

import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import '../styles/globals.css';

const MyApp = ({ Component, pageProps }) => (
  <ThemeProvider attribute="class">
    <Navbar />
    <div className="dark:bg-nft-dark bg-white min-h-screen">
      <Component {...pageProps} />
    </div>
    <Script src="https://kit.fontawesome.com/054fc2b270.js" crossorigin="anonymous" />
    <Footer />
  </ThemeProvider>
);

export default MyApp;
