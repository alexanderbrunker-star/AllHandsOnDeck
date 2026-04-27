import { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export function HomePage() {
  const navigate = useNavigate();
  const [code, setCode] = useState('');

  return (
    <div className="center-stack">
      <span className="pill pill-gold">⚓︎ by Captain Leopard</span>
      <h1 className="title">All Hands<br/>on Deck</h1>
      <p className="subtitle">
        Web-Viewer für Captain&apos;s Live-Group-Photo-Session.<br/>
        Code unten eintippen oder den QR-Code des Captains scannen.
      </p>
      <input
        className="id-input"
        placeholder="ABCDEF1234"
        value={code}
        onChange={e => setCode(e.target.value.toUpperCase())}
        autoCapitalize="characters"
        autoCorrect="off"
        autoComplete="off"
        spellCheck={false}
      />
      <button
        className="btn-primary"
        disabled={code.length < 6}
        onClick={() => navigate(`/join/${code}`)}
        style={{ opacity: code.length < 6 ? 0.5 : 1 }}
      >
        Beitreten →
      </button>
      <p className="muted-note">
        Keine Installation. Keine Anmeldung.
      </p>
    </div>
  );
}
