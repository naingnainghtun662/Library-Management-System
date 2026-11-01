/**
 * API HELPER
 * ----------------------------------------------------------------------------
 * One shared "axios" instance that every page uses to talk to the back end.
 *   - baseURL '/api': page code can write api.get('/books') instead of the full URL.
 *   - The interceptor below runs before EVERY request and attaches the login token:
 *         Authorization: Bearer <token>
 *     The server's authenticateToken middleware reads this header to know who is asking.
 */
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api',
});

api.interceptors.request.use((config) => {
  // The token is saved in the browser's localStorage when the user logs in (see App.tsx)
  const token = localStorage.getItem('library_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
