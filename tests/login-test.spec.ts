import { test, expect } from '@playwright/test';

test('login check', async ({ page }) => {
  await page.goto('http://localhost:9292/');
  await page.getByRole('textbox', { name: 'Email' }).fill('admin');
  await page.getByRole('textbox', { name: 'Password' }).fill('admin');
  await page.getByRole('button', { name: 'Sign In' }).click();

  // Wait for either a success or failure condition
  const success = await page.locator('text=Dashboard').first().isVisible().catch(() => false);
  
  expect(success).toBeTruthy(); // This will mark the test as failed if false
});
