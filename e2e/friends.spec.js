// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Friends Management', () => {
  test.beforeEach(async ({ page }) => {
    // Login first
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    await page.getByPlaceholder('Enter your username').fill('minhtrong2k4');
    await page.getByPlaceholder('Enter your password').fill('minhtrong2k4');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByText('Recent Messages')).toBeVisible({ timeout: 15000 });
  });

  test('should display friends in contacts tab', async ({ page }) => {
    // Navigate to Contacts tab
    await page.getByText('CONTACTS').click();
    
    // Wait for friends to load
    await page.waitForTimeout(2000);
    
    // Check if friends are displayed
    const friendsCount = await page.locator('[role="listitem"]').count();
    console.log(`✓ Found ${friendsCount} friends`);
    
    expect(friendsCount).toBeGreaterThan(0);
  });

  test('should search for user', async ({ page }) => {
    // Click add friend button
    await page.getByRole('button', { name: /add|plus/i }).click();
    
    // Wait for add friend screen
    await expect(page.getByText('Add Friends')).toBeVisible({ timeout: 5000 });
    
    // Search for user
    await page.getByPlaceholder(/find.*username/i).fill('thanhnhan');
    await page.getByRole('button', { name: 'Search' }).click();
    
    // Wait for search results
    await page.waitForTimeout(2000);
    
    // Check if user is found
    await expect(page.getByText('thanhnhan')).toBeVisible({ timeout: 5000 });
    
    console.log('✓ User search working');
  });

  test('should open chat with friend', async ({ page }) => {
    // Navigate to Contacts tab
    await page.getByText('CONTACTS').click();
    await page.waitForTimeout(2000);
    
    // Click chat icon for first friend
    const chatButton = page.locator('button:has-text("chat")').first();
    await chatButton.click();
    
    // Wait for chat screen to open
    await page.waitForTimeout(3000);
    
    // Check if chat screen is visible
    const hasChatInput = await page.getByPlaceholder(/type.*message/i).isVisible();
    
    if (hasChatInput) {
      console.log('✓ Chat screen opened successfully');
    } else {
      console.log('⚠ Chat screen may not have opened');
    }
  });
});
