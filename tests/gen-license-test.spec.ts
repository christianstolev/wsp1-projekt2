import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('http://localhost:9292/');
  await page.getByRole('textbox', { name: 'Email' }).click();
  await page.getByRole('textbox', { name: 'Email' }).fill('admin');
  await page.getByRole('textbox', { name: 'Password' }).click();
  await page.getByRole('textbox', { name: 'Password' }).fill('admin');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.goto('http://localhost:9292/licenses');
  await page.getByRole('textbox', { name: 'Product Name' }).click();
  await page.getByRole('textbox', { name: 'Product Name' }).fill('Tets Product');
  await page.getByRole('textbox', { name: 'Expiration Date' }).fill('2025-04-25');
  await page.getByRole('button', { name: 'Generate License Keys' }).click();
  
  const creditstext = await page.locator('//*[@id="dashboard"]/div[1]/div[1]/div');
  await expect(creditstext).toHaveText("50");
});