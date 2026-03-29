// @ts-check
const { test, expect } = require('@playwright/test');
const { login } = require('./helpers/auth-helper');

test.describe('Simple Login Test', () => {
  test('should successfully login and reach home screen', async ({ page }) => {
    console.log('\n=== Starting Simple Login Test ===\n');
    
    // Perform login
    await login(page);
    
    // Wait a bit for home screen to fully load
    await page.waitForTimeout(3000);
    
    // Take screenshot
    await page.screenshot({ path: 'test-results/home-screen.png', fullPage: true });
    
    // Verify we're on home screen by checking for navigation tabs
    const hasChatsTab = await page.locator('text=CHATS').isVisible({ timeout: 5000 });
    const hasContactsTab = await page.locator('text=CONTACTS').isVisible({ timeout: 5000 });
    const hasProfileTab = await page.locator('text=PROFILE').isVisible({ timeout: 5000 });
    
    console.log(`\nHome Screen Elements:`);
    console.log(`- CHATS tab: ${hasChatsTab ? '✓' : '✗'}`);
    console.log(`- CONTACTS tab: ${hasContactsTab ? '✓' : '✗'}`);
    console.log(`- PROFILE tab: ${hasProfileTab ? '✓' : '✗'}`);
    
    // Verify all tabs are present
    expect(hasChatsTab).toBeTruthy();
    expect(hasContactsTab).toBeTruthy();
    expect(hasProfileTab).toBeTruthy();
    
    console.log('\n✓ Login test passed!\n');
  });
});
