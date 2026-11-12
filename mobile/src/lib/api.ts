// Small JSON client for the FastAPI backend (backend/api), with a bearer token.
export const API_URL = 'https://quanlyhoctap-svtj.onrender.com';

/** An error answered by the API, or a network failure (status 0). */
export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
  }

  get offline() {
    return this.status === 0;
  }
}

// Free Render instances sleep; the first request can take about a minute.
const TIMEOUT_MS = 75_000;

let token: string | null = null;
let unauthorized: (() => void) | null = null;

export const api = {
  get token() {
    return token;
  },
  set token(value: string | null) {
    token = value;
  },
  /** Called when the server rejects the token (expired or revoked). */
  onUnauthorized(fn: (() => void) | null) {
    unauthorized = fn;
  },

  get: <T = any>(path: string, query?: Record<string, string>) =>
    send<T>('GET', path + (query ? '?' + new URLSearchParams(query).toString() : '')),
  post: <T = any>(path: string, body?: unknown) => send<T>('POST', path, body ?? {}),
  put: <T = any>(path: string, body: unknown) => send<T>('PUT', path, body),
  patch: <T = any>(path: string, body: unknown) => send<T>('PATCH', path, body),
  delete: <T = any>(path: string) => send<T>('DELETE', path),

  /** Uploads raw bytes (the avatar) read from a local file uri. */
  async putFile<T = any>(path: string, uri: string, contentType: string) {
    const blob = await (await fetch(uri)).blob();
    return send<T>('PUT', path, blob, contentType);
  },

  /** Image source for pictures served by the API (they need the auth header). */
  imageSource(path: string) {
    return { uri: API_URL + path, headers: token ? { Authorization: `Bearer ${token}` } : undefined };
  },
};

async function send<T>(
  method: string,
  path: string,
  body?: unknown,
  contentType = 'application/json',
): Promise<T> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
  let res: Response;
  try {
    res = await fetch(API_URL + path, {
      method,
      signal: controller.signal,
      headers: {
        'Content-Type': contentType,
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body:
        body === undefined
          ? undefined
          : contentType === 'application/json'
            ? JSON.stringify(body)
            : (body as Blob),
    });
  } catch {
    throw new ApiError(
      0,
      controller.signal.aborted
        ? 'Máy chủ phản hồi quá lâu, thử lại nhé'
        : 'Không kết nối được máy chủ, kiểm tra mạng nhé',
    );
  } finally {
    clearTimeout(timer);
  }
  if (res.status === 401 && token) unauthorized?.();
  const text = await res.text();
  if (res.status >= 400) throw new ApiError(res.status, detail(text, res.status));
  return (text ? JSON.parse(text) : null) as T;
}

function detail(text: string, status: number): string {
  try {
    const d = JSON.parse(text).detail;
    if (typeof d === 'string') return d;
    if (Array.isArray(d) && d[0]?.msg) return d[0].msg;
  } catch {
    // not JSON
  }
  return `Lỗi máy chủ (${status})`;
}

/** A message fit to show the learner. */
export function errorText(e: unknown): string {
  if (e instanceof ApiError) return e.message;
  return 'Có lỗi xảy ra, thử lại nhé';
}
