export default function Home() {
  return (
    <main className="hero">
      <nav className="nav">
        <span className="logo">Acme Analytics</span>
        <a className="nav-link" href="#pricing">Pricing</a>
        <a className="nav-link" href="#login">Log in</a>
      </nav>
      <section className="hero-body">
        <h1>Welcome to Acme Analytics</h1>
        <p className="lead">Dashboards for small teams. Connect your data in minutes.</p>
        <a className="btn btn-primary" href="#signup">Start free trial</a>
        <a className="btn btn-secondary" href="#demo">Book a demo</a>
      </section>
      <section className="features">
        <div className="card">
          <h3>Fast</h3>
          <p>Queries return in under a second.</p>
        </div>
        <div className="card">
          <h3>Simple</h3>
          <p>No SQL required to build a chart.</p>
        </div>
        <div className="card">
          <h3>Shared</h3>
          <p>Invite your whole team for free.</p>
        </div>
      </section>
      <footer className="footer">© 2026 Acme Analytics</footer>
    </main>
  );
}
