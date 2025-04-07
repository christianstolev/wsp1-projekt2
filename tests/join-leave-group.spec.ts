import { test, expect } from '@playwright/test';

test('join/leave group test', async ({ page }) => {
  await page.goto('http://localhost:9292/');
  await page.getByRole('textbox', { name: 'Email' }).fill('admin');
  await page.getByRole('textbox', { name: 'Password' }).fill('admin');
  await page.getByRole('button', { name: 'Sign In' }).click();
  
  await page.goto('http://localhost:9292/groups');
  const groupRow = page.getByRole('row', { name: 'Cool Kids Club 1 Join' });
 
  const joinButton = page.locator('xpath=//*[@id="dashboard"]/div/table/tbody/tr[1]/td[4]/button');
  if(await joinButton.textContent() == "Join")
  {
    console.log("Joining group...")
    await joinButton.click();
    await expect(joinButton).toHaveText('Leave');
  }
  else
  {
    console.log("Leaving group...")
    await joinButton.click();
    await expect(joinButton).toHaveText('Join');
  }
  
});