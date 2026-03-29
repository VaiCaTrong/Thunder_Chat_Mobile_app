// @ts-check
const { test } = require('@playwright/test');

test.describe('Inspect Login Form', () => {
  test('should inspect login form elements', async ({ page }) => {
    console.log('\n🔍 Starting form inspection...\n');
    
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000); // Wait for Flutter to fully load
    
    console.log('📸 Taking screenshot of login page...');
    await page.screenshot({ path: 'test-results/login-page.png', fullPage: true });
    
    // Get page title
    const title = await page.title();
    console.log(`Page title: ${title}`);
    
    // Get all text content
    console.log('\n📝 Page text content:');
    const bodyText = await page.locator('body').textContent();
    console.log(bodyText?.substring(0, 1000));
    
    // Find all input elements
    console.log('\n🔍 Looking for input elements...');
    const inputs = page.locator('input');
    const inputCount = await inputs.count();
    console.log(`Found ${inputCount} input elements`);
    
    for (let i = 0; i < inputCount; i++) {
      const input = inputs.nth(i);
      const type = await input.getAttribute('type').catch(() => 'unknown');
      const placeholder = await input.getAttribute('placeholder').catch(() => 'none');
      const ariaLabel = await input.getAttribute('aria-label').catch(() => 'none');
      const name = await input.getAttribute('name').catch(() => 'none');
      const id = await input.getAttribute('id').catch(() => 'none');
      const isVisible = await input.isVisible().catch(() => false);
      
      console.log(`\nInput ${i}:`);
      console.log(`  - Type: ${type}`);
      console.log(`  - Placeholder: ${placeholder}`);
      console.log(`  - Aria-label: ${ariaLabel}`);
      console.log(`  - Name: ${name}`);
      console.log(`  - ID: ${id}`);
      console.log(`  - Visible: ${isVisible}`);
    }
    
    // Find all buttons
    console.log('\n🔍 Looking for button elements...');
    const buttons = page.locator('button');
    const buttonCount = await buttons.count();
    console.log(`Found ${buttonCount} button elements`);
    
    for (let i = 0; i < buttonCount; i++) {
      const button = buttons.nth(i);
      const text = await button.textContent().catch(() => 'no text');
      const type = await button.getAttribute('type').catch(() => 'unknown');
      const ariaLabel = await button.getAttribute('aria-label').catch(() => 'none');
      const isVisible = await button.isVisible().catch(() => false);
      
      console.log(`\nButton ${i}:`);
      console.log(`  - Text: ${text}`);
      console.log(`  - Type: ${type}`);
      console.log(`  - Aria-label: ${ariaLabel}`);
      console.log(`  - Visible: ${isVisible}`);
    }
    
    // Check for Flutter-specific elements
    console.log('\n🔍 Looking for Flutter-specific elements...');
    const flutterInputs = page.locator('flt-text-editing-host');
    const flutterInputCount = await flutterInputs.count();
    console.log(`Found ${flutterInputCount} Flutter text editing hosts`);
    
    // Check for form elements
    console.log('\n🔍 Looking for form elements...');
    const forms = page.locator('form');
    const formCount = await forms.count();
    console.log(`Found ${formCount} form elements`);
    
    // Try to find elements by text
    console.log('\n🔍 Looking for text elements...');
    const welcomeText = await page.locator('text=/Welcome|Login|Sign In/i').count();
    console.log(`Found ${welcomeText} welcome/login text elements`);
    
    const usernameText = await page.locator('text=/Username/i').count();
    console.log(`Found ${usernameText} username text elements`);
    
    const passwordText = await page.locator('text=/Password/i').count();
    console.log(`Found ${passwordText} password text elements`);
    
    // Get HTML structure
    console.log('\n📋 HTML structure of body:');
    const html = await page.locator('body').innerHTML();
    console.log(html.substring(0, 2000));
    
    console.log('\n✅ Inspection complete! Check test-results/login-page.png');
    
    // Keep browser open for manual inspection
    await page.waitForTimeout(5000);
  });
  
  test('should try to interact with form', async ({ page }) => {
    console.log('\n🧪 Testing form interaction...\n');
    
    await page.goto('http://localhost:5173');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);
    
    // Try clicking on the page to focus
    console.log('Clicking on page to focus...');
    await page.click('body');
    await page.waitForTimeout(500);
    
    // Try typing directly
    console.log('Trying to type username...');
    await page.keyboard.type('phamminhtrong324');
    await page.waitForTimeout(1000);
    
    await page.screenshot({ path: 'test-results/after-username-type.png' });
    
    // Press Tab to move to next field
    console.log('Pressing Tab...');
    await page.keyboard.press('Tab');
    await page.waitForTimeout(500);
    
    // Type password
    console.log('Trying to type password...');
    await page.keyboard.type('123456');
    await page.waitForTimeout(1000);
    
    await page.screenshot({ path: 'test-results/after-password-type.png' });
    
    // Press Enter to submit
    console.log('Pressing Enter to submit...');
    await page.keyboard.press('Enter');
    await page.waitForTimeout(3000);
    
    await page.screenshot({ path: 'test-results/after-submit.png' });
    
    // Check if logged in
    const isLoggedIn = await page.locator('text=/Recent Messages|CHATS|Solaris/i').isVisible({ timeout: 5000 }).catch(() => false);
    
    if (isLoggedIn) {
      console.log('✅ Successfully logged in!');
    } else {
      console.log('❌ Login failed or home page not detected');
    }
    
    await page.waitForTimeout(3000);
  });
});
