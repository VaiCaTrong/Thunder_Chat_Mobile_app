// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Chat Functionality', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    await page.getByPlaceholder('Enter your username').fill('minhtrong2k4');
    await page.getByPlaceholder('Enter your password').fill('minhtrong2k4');
    await page.getByRole('button', { name: 'Sign In' }).click();
    
    await expect(page.getByText('Recent Messages')).toBeVisible({ timeout: 15000 });
  });

  test('should display conversations in chat tab', async ({ page }) => {
    // Should be on CHATS tab by default
    await page.waitForTimeout(2000);
    
    // Check for conversations or empty state
    const hasConversations = await page.locator('[role="listitem"]').count() > 0;
    const hasEmptyState = await page.getByText(/no conversations/i).isVisible();
    
    if (hasConversations) {
      console.log('✓ Conversations displayed');
    } else if (hasEmptyState) {
      console.log('✓ Empty state displayed (no conversations yet)');
    }
    
    expect(hasConversations || hasEmptyState).toBeTruthy();
  });

  test('should create new chat', async ({ page }) => {
    // Click new chat button
    const newChatButton = page.getByRole('button', { name: /new|plus|add/i }).first();
    await newChatButton.click();
    
    // Wait for new chat screen
    await page.waitForTimeout(2000);
    
    // Check if friend selection screen is visible
    const hasFriendList = await page.getByText(/select.*friend|new chat/i).isVisible();
    
    if (hasFriendList) {
      console.log('✓ New chat screen opened');
    }
  });

  test('should send message in chat', async ({ page }) => {
    // Navigate to contacts and open chat
    await page.getByText('CONTACTS').click();
    await page.waitForTimeout(2000);
    
    // Click chat icon
    const chatButton = page.locator('button:has-text("chat")').first();
    if (await chatButton.isVisible()) {
      await chatButton.click();
      await page.waitForTimeout(3000);
      
      // Try to send a message
      const messageInput = page.getByPlaceholder(/type.*message/i);
      if (await messageInput.isVisible()) {
        await messageInput.fill('Test message from Playwright');
        
        // Click send button
        const sendButton = page.getByRole('button', { name: /send/i });
        if (await sendButton.isVisible()) {
          await sendButton.click();
          await page.waitForTimeout(1000);
          
          // Check if message appears
          await expect(page.getByText('Test message from Playwright')).toBeVisible({ timeout: 5000 });
          console.log('✓ Message sent successfully');
        }
      }
    } else {
      console.log('⚠ No friends available to chat with');
    }
  });
});
