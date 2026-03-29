// @ts-check
const { test } = require('@playwright/test');

test('manual login with clicks', async ({ page }) => {
  console.log('\n🔐 Testing manual login...\n');
  
  await page.goto('http://localhost:5173');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(5000);
  
  console.log('📸 Initial page');
  await page.screenshot({ path: 'test-results/step-1-initial.png' });
  
  // Find all visible inputs
  const inputs = page.locator('input:visible');
  const count = await inputs.count();
  console.log(`Found ${count} visible inputs`);
  
  if (count < 2) {
    console.log('❌ Not enough inputs found');
    return;
  }
  
  // Click and fill first input (username)
  console.log('\n📝 Step 1: Fill username');
  const usernameInput = inputs.nth(0);
  await usernameInput.click();
  await page.waitForTimeout(500);
  await usernameInput.fill('phamminhtrong324');
  await page.waitForTimeout(1000);
  
  console.log('📸 After username');
  await page.screenshot({ path: 'test-results/step-2-username.png' });
  
  // Click and fill second input (password)
  console.log('\n📝 Step 2: Fill password');
  const passwordInput = inputs.nth(1);
  await passwordInput.click();
  await page.waitForTimeout(500);
  await passwordInput.fill('123456');
  await page.waitForTimeout(1000);
  
  console.log('📸 After password');
  await page.screenshot({ path: 'test-results/step-3-password.png' });
  
  // Find and click Sign In button
  console.log('\n🔘 Step 3: Click Sign In button');
  const buttons = page.locator('button:visible');
  const buttonCount = await buttons.count();
  console.log(`Found ${buttonCount} visible buttons`);
  
  // Try to find Sign In button
  let signInButton = null;
  for (let i = 0; i < buttonCount; i++) {
    const button = buttons.nth(i);
    const text = await button.textContent();
    console.log(`Button ${i}: "${text}"`);
    
    if (text && text.toLowerCase().includes('sign')) {
      signInButton = button;
      console.log(`✓ Found Sign In button at index ${i}`);
      break;
    }
  }
  
  if (!signInButton) {
    console.log('⚠ Sign In button not found by text, using first button');
    signInButton = buttons.first();
  }
  
  await signInButton.click();
  console.log('✓ Clicked Sign In button');
  
  await page.waitForTimeout(5000);
  
  console.log('📸 After submit');
  await page.screenshot({ path: 'test-results/step-4-after-submit.png' });
  
  // Check if logged in
  const pageText = await page.locator('body').textContent();
  console.log('\n📄 Page content after login:');
  console.log(pageText?.substring(0, 500));
  
  const isLoggedIn = await page.locator('text=/Recent Messages|CHATS|Solaris/i').isVisible({ timeout: 5000 }).catch(() => false);
  
  if (isLoggedIn) {
    console.log('\n✅ Successfully logged in!');
    await page.screenshot({ path: 'test-results/step-5-logged-in.png' });
  } else {
    console.log('\n❌ Login failed');
    
    // Check for error messages
    const hasError = await page.locator('text=/error|invalid|incorrect|failed/i').isVisible().catch(() => false);
    if (hasError) {
      const errorText = await page.locator('text=/error|invalid|incorrect|failed/i').textContent();
      console.log(`Error message: ${errorText}`);
    }
  }
  
  await page.waitForTimeout(3000);
});
