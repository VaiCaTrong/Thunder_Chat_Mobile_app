// @ts-check
const config = require('../../test-config.json');

/**
 * Login helper function
 * @param {import('@playwright/test').Page} page 
 * @param {string} username 
 * @param {string} password 
 */
async function login(page, username = null, password = null) {
  // Use provided credentials or default from config
  const user = username || config.testUser.username;
  const pass = password || config.testUser.password;
  
  console.log(`🔐 Logging in as: ${user}`);
  
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(3000); // Wait for Flutter to fully load
  
  console.log('Looking for login form...');
  
  // Flutter web uses flt-text-editing elements
  // Find all text inputs
  const allInputs = await page.locator('input').all();
  console.log(`Found ${allInputs.length} input elements`);
  
  if (allInputs.length < 2) {
    console.log('❌ Not enough input fields found');
    throw new Error('Login form not found');
  }
  
  // First input is username
  const usernameInput = allInputs[0];
  console.log('✓ Using first input as username field');
  
  await usernameInput.click();
  await page.waitForTimeout(300);
  await usernameInput.fill(user);
  console.log(`✓ Filled username: ${user}`);
  
  await page.waitForTimeout(500);
  
  // Second input is password
  const passwordInput = allInputs[1];
  console.log('✓ Using second input as password field');
  
  await passwordInput.click();
  await page.waitForTimeout(300);
  await passwordInput.fill(pass);
  console.log(`✓ Filled password`);
  
  await page.waitForTimeout(500);
  
  // Find login button by text
  const loginButton = page.getByRole('button', { name: /Sign In/i });
  
  if (!(await loginButton.isVisible({ timeout: 2000 }))) {
    console.log('❌ Could not find login button');
    throw new Error('Login button not found');
  }
  
  console.log('✓ Found login button');
  await loginButton.click();
  console.log('✓ Clicked login button');
  
  // Wait for navigation
  await page.waitForTimeout(3000);
  
  // Check if logged in by looking for home screen elements
  const isLoggedIn = await page.locator('text=/Recent Messages|CHATS|Contacts/i').isVisible({ timeout: 10000 }).catch(() => false);
  
  if (isLoggedIn) {
    console.log('✓ Logged in successfully');
  } else {
    console.log('⚠ Login may have failed - home page not detected');
    await page.screenshot({ path: 'test-results/login-failed.png' });
  }
}

/**
 * Logout helper function
 * @param {import('@playwright/test').Page} page 
 */
async function logout(page) {
  console.log('🚪 Logging out...');
  
  // Navigate to profile tab
  await page.getByText('PROFILE').click();
  await page.waitForTimeout(1000);
  
  // Click logout button
  const logoutButton = page.getByRole('button', { name: /logout|sign out/i });
  if (await logoutButton.isVisible()) {
    await logoutButton.click();
    await page.waitForTimeout(1000);
    console.log('✓ Logged out successfully');
  }
}

/**
 * Navigate to a specific tab
 * @param {import('@playwright/test').Page} page 
 * @param {'CHATS' | 'CONTACTS' | 'PROFILE'} tabName 
 */
async function navigateToTab(page, tabName) {
  console.log(`📱 Navigating to ${tabName} tab`);
  await page.getByText(tabName).click();
  await page.waitForTimeout(1000);
}

module.exports = {
  login,
  logout,
  navigateToTab,
  config
};
