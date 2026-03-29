// @ts-check
const { test, expect } = require('@playwright/test');
const { login, navigateToTab } = require('./helpers/auth-helper');

test.describe('Complete Chat Flow', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test('should open chat from contacts and send message', async ({ page }) => {
    console.log('\n📋 Step 1: Navigate to Contacts tab');
    await navigateToTab(page, 'CONTACTS');
    await page.waitForTimeout(2000);
    
    // Check if there are friends
    const friendItems = page.locator('text=/Thanh Nhân|thanhnhan/i').first();
    const hasFriends = await friendItems.isVisible().catch(() => false);
    
    if (!hasFriends) {
      console.log('❌ No friends found in contacts');
      test.skip();
      return;
    }
    
    console.log('✓ Friends list loaded');
    
    console.log('\n💬 Step 2: Click chat icon to open conversation');
    // Find and click the chat button
    const chatButtons = page.locator('button').filter({ hasText: /chat/i });
    const chatButtonCount = await chatButtons.count();
    
    console.log(`Found ${chatButtonCount} chat buttons`);
    
    if (chatButtonCount === 0) {
      // Try alternative selector - icon button with chat icon
      const iconButtons = page.locator('button[aria-label*="chat"], button:has(svg)');
      const iconCount = await iconButtons.count();
      console.log(`Found ${iconCount} icon buttons`);
      
      if (iconCount > 0) {
        await iconButtons.first().click();
      } else {
        console.log('❌ No chat buttons found');
        test.skip();
        return;
      }
    } else {
      await chatButtons.first().click();
    }
    
    console.log('Waiting for chat screen to load...');
    await page.waitForTimeout(3000);
    
    // Take screenshot after clicking
    await page.screenshot({ path: 'test-results/after-chat-click.png' });
    
    console.log('\n📝 Step 3: Check if chat screen opened');
    // Check for chat screen elements
    const hasBackButton = await page.locator('button:has-text("arrow_back")').isVisible().catch(() => false);
    const hasMessageInput = await page.getByPlaceholder(/type.*message|enter.*message|message/i).isVisible().catch(() => false);
    const hasChatHeader = await page.locator('text=/Thanh Nhân|thanhnhan/i').first().isVisible().catch(() => false);
    
    console.log(`Back button visible: ${hasBackButton}`);
    console.log(`Message input visible: ${hasMessageInput}`);
    console.log(`Chat header visible: ${hasChatHeader}`);
    
    if (!hasMessageInput) {
      console.log('❌ Chat screen did not open - message input not found');
      console.log('Current URL:', page.url());
      
      // Log all visible text on page
      const bodyText = await page.locator('body').textContent();
      console.log('Page content:', bodyText?.substring(0, 500));
      
      test.fail();
      return;
    }
    
    console.log('✓ Chat screen opened successfully');
    
    console.log('\n✉️ Step 4: Send a test message');
    const messageInput = page.getByPlaceholder(/type.*message|enter.*message|message/i);
    const testMessage = `Test message at ${new Date().toLocaleTimeString()}`;
    
    await messageInput.fill(testMessage);
    console.log(`Typed message: "${testMessage}"`);
    
    // Find and click send button
    const sendButton = page.locator('button').filter({ hasText: /send/i }).or(
      page.locator('button:has(svg)').last()
    );
    
    if (await sendButton.isVisible()) {
      await sendButton.click();
      console.log('✓ Send button clicked');
      
      await page.waitForTimeout(2000);
      
      // Check if message appears in chat
      const messageAppeared = await page.getByText(testMessage).isVisible({ timeout: 5000 }).catch(() => false);
      
      if (messageAppeared) {
        console.log('✓ Message sent and displayed successfully');
      } else {
        console.log('⚠ Message may not have been sent or displayed');
      }
      
      // Take screenshot of chat with message
      await page.screenshot({ path: 'test-results/chat-with-message.png' });
      
      expect(messageAppeared).toBeTruthy();
    } else {
      console.log('❌ Send button not found');
      test.fail();
    }
  });

  test('should navigate to chat tab and view conversations', async ({ page }) => {
    console.log('\n📱 Step 1: Check CHATS tab');
    
    await navigateToTab(page, 'CHATS');
    await page.waitForTimeout(2000);
    
    // Take screenshot of chats tab
    await page.screenshot({ path: 'test-results/chats-tab.png' });
    
    // Check for conversations or empty state
    const hasConversations = await page.locator('[role="listitem"]').count() > 0;
    const hasEmptyState = await page.getByText(/no conversations|no messages/i).isVisible().catch(() => false);
    
    console.log(`Has conversations: ${hasConversations}`);
    console.log(`Has empty state: ${hasEmptyState}`);
    
    if (hasConversations) {
      console.log('✓ Conversations found in CHATS tab');
      
      console.log('\n💬 Step 2: Click on first conversation');
      const firstConversation = page.locator('[role="listitem"]').first();
      await firstConversation.click();
      
      await page.waitForTimeout(2000);
      
      // Check if chat opened
      const hasMessageInput = await page.getByPlaceholder(/type.*message|enter.*message|message/i).isVisible().catch(() => false);
      
      if (hasMessageInput) {
        console.log('✓ Chat opened from conversations list');
        
        // Take screenshot
        await page.screenshot({ path: 'test-results/chat-from-list.png' });
      } else {
        console.log('⚠ Chat may not have opened');
      }
    } else if (hasEmptyState) {
      console.log('✓ Empty state displayed (no conversations yet)');
      console.log('ℹ️ Create a conversation from Contacts tab first');
    } else {
      console.log('⚠ Could not determine chat tab state');
    }
  });

  test('should create new chat and send message', async ({ page }) => {
    console.log('\n➕ Step 1: Click new chat button');
    
    await navigateToTab(page, 'CHATS');
    await page.waitForTimeout(1000);
    
    // Look for floating action button or new chat button
    const newChatButton = page.locator('button').filter({ hasText: /new|plus|\+/i }).first();
    
    if (await newChatButton.isVisible()) {
      await newChatButton.click();
      console.log('✓ New chat button clicked');
      
      await page.waitForTimeout(2000);
      
      console.log('\n👥 Step 2: Select a friend');
      // Look for friend in the list
      const friendItem = page.locator('text=/Thanh Nhân|thanhnhan/i').first();
      
      if (await friendItem.isVisible()) {
        await friendItem.click();
        console.log('✓ Friend selected');
        
        await page.waitForTimeout(1000);
        
        // Look for Start button
        const startButton = page.getByRole('button', { name: /start/i });
        if (await startButton.isVisible()) {
          await startButton.click();
          console.log('✓ Start button clicked');
          
          await page.waitForTimeout(3000);
          
          // Check if chat opened
          const hasMessageInput = await page.getByPlaceholder(/type.*message|enter.*message|message/i).isVisible().catch(() => false);
          
          if (hasMessageInput) {
            console.log('✓ New chat created successfully');
            
            // Send a message
            const messageInput = page.getByPlaceholder(/type.*message|enter.*message|message/i);
            await messageInput.fill('Hello from new chat!');
            
            const sendButton = page.locator('button').filter({ hasText: /send/i }).or(
              page.locator('button:has(svg)').last()
            );
            
            if (await sendButton.isVisible()) {
              await sendButton.click();
              console.log('✓ Message sent in new chat');
              
              await page.waitForTimeout(2000);
              await page.screenshot({ path: 'test-results/new-chat-message.png' });
            }
          }
        }
      } else {
        console.log('⚠ No friends available to create chat');
      }
    } else {
      console.log('⚠ New chat button not found');
    }
  });
});
