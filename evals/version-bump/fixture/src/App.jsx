export default function App() {
  return (
    <>
      <main>
        <section className="hero" aria-labelledby="hero-title">
          <p className="eyebrow">Acme Studio</p>
          <h1 id="hero-title">Fotografía de producto que vende sola</h1>
          <p className="lead">
            Sesiones en 48 horas, fondos limpios y recortes listos para tu tienda.
          </p>
          <a className="button" href="#contacto">
            Reservar sesión
          </a>
        </section>
      </main>
      <footer className="site-footer">
        <span>© 2026 Acme Studio</span>
        <span className="site-version" title="Build">
          v{__APP_VERSION__} · {__COMMIT__}
        </span>
      </footer>
    </>
  );
}
