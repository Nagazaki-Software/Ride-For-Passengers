// Simple script to call the local Functions emulator callable endpoint
// for saveCardPayment with fake data, to verify wiring/logs.
(async () => {
  const url = 'http://127.0.0.1:5001/quick-b108e/us-central1/saveCardPayment';
  const body = { data: { paymentNonce: 'fake-nonce', isProd: false } };
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    const text = await res.text();
    console.log('HTTP', res.status);
    console.log(text);
  } catch (e) {
    console.error('Request failed:', e);
    process.exit(1);
  }
})();

