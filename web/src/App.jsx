import Nav from './components/Nav.jsx';
import Hero from './components/Hero.jsx';
import About from './components/About.jsx';
import TechStack from './components/TechStack.jsx';
import Projects from './components/Projects.jsx';
import Architecture from './components/Architecture.jsx';
import Certifications from './components/Certifications.jsx';
import Timeline from './components/Timeline.jsx';
import Contact from './components/Contact.jsx';
import Footer from './components/Footer.jsx';

export default function App() {
  return (
    <div className="min-h-screen">
      <Nav />
      <main>
        <Hero />
        <About />
        <TechStack />
        <Projects />
        <Architecture />
        <Certifications />
        <Timeline />
        <Contact />
      </main>
      <Footer />
    </div>
  );
}
