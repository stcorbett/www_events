const BROWSER = {
  messenger: /\bFB[\w_]+\/(Messenger|MESSENGER)/,
  facebook: /\bFB[\w_]+\//,
  twitter: /\bTwitter/i,
  line: /\bLine\//i,
  wechat: /\bMicroMessenger\//i,
  puffin: /\bPuffin/i,
  miui: /\bMiuiBrowser\//i,
  instagram: /\bInstagram/i,
  chrome: /\bCrMo\b|CriOS|Android.*Chrome\/[.0-9]* (Mobile)?/,
  safari: /Version.*Mobile.*Safari|Safari.*Mobile|MobileSafari/,
  ie: /IEMobile|MSIEMobile/,
  firefox: /fennec|firefox.*maemo|(Mobile|Tablet).*Firefox|Firefox.*Mobile|FxiOS/,
};

class InApp {

  ua = '';

  constructor(useragent = window.navigator.userAgent) {
    this.ua = useragent || '';
  }

  get browser() {
    return Object.keys(BROWSER).find(name => BROWSER[name].test(this.ua)) || 'other';
  }

  get isMobile() {
    return /(iPad|iPhone|Android|Mobile)/i.test(this.ua) || false;
  }

  get isDesktop() {
    return !this.isMobile;
  }

  get isInApp() {
    const rules = [
      '\\bFB[\\w_]+\\/',
      '\\bInstagram\\b',
      '\\bLine\\/',
      '\\bMicroMessenger\\/',
      '\\bTwitter\\b',
      'WebView',
      '(iPhone|iPod|iPad)(?!.*Safari\/)',
      'Android.*(wv)',
    ];
    const regex = new RegExp(`(${rules.join('|')})`, 'ig');
    return Boolean(this.ua.match(regex));
  }
}

window.InApp = InApp;
