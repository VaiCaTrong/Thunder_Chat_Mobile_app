// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Authentication Flow', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/');
    
    // Wait for app to load
    await page.waitForLoadState('networkidle');
    
    // Check if we're on login page
    await expect(page.getByText('Welcome Back')).toBeVisible({ timeout: 10000 });
    
    // Fill login form
    await page.getByPlaceholder('Enter your username').fill('minhtrong2k4');
    await page.getByPlaceholder('Enter your password').fill('minhtrong2k4');
    
    // Click login button
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    // Wait for navigation to home
    await expect(page.getByText('Recent Messages')).toBeVisible({ timeout: 15000 });
    
    console.log('✓ Login successful');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/');
    
    await page.waitForLoadState('networkidle');
    await expect(page.getByText('Welcome Back')).toBeVisible({ timeout: 10000 });
    
    // Fill with wrong credentials
    await page.getByPlaceholder('Enter your username').fill('wronguser');
    await page.getByPlaceholder('Enter your password').fill('wrongpass');
    
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    // Should show error message
    await expect(page.getByText(/incorrect|invalid|failed/i)).toBeVisible({ timeout: 5000 });
    
    console.log('✓ Error message shown for invalid credentials');
  });
});
