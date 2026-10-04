import { render, screen } from '@testing-library/react';
import pkg from '../package.json';
import App from './App.jsx';

describe('App', () => {
  it('renders the hero title', () => {
    render(<App />);
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('Fotografía de producto');
  });

  it('has the primary call to action', () => {
    render(<App />);
    expect(screen.getByRole('link', { name: 'Reservar sesión' })).toHaveAttribute('href', '#contacto');
  });

  it('shows the package version in the footer stamp', () => {
    render(<App />);
    expect(screen.getByTitle('Build')).toHaveTextContent(`v${pkg.version}`);
  });
});
