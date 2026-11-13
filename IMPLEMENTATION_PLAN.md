# Implementation Plan: Analytics Refactor, Category Budgets, Profile Icon Removal

## Overview
This document outlines the implementation plan for the three main tasks.

## Step 1: Global Profile Icon Removal
- [ ] Modify `app_header.dart` to remove the profile avatar button logic entirely
- [ ] The right-side empty slot will remain clean (no back action needed on main screens)

## Step 2: Analytics Screen Cleanup
- [ ] Remove the "Analytics" title header row
- [ ] Remove the "Spending On Track" alert banner
- [ ] Keep only actionable alerts when budgets are near/exceeded

## Step 3: Monthly Category Budget Implementation

### Database Changes (`db_helper.dart`)
- [ ] Add `monthly_budget` column to categories table
- [ ] Add method `updateCategoryBudget(int id, double? limit)`
- [ ] Update `getAllCategories()` to return budget info

### Model Changes (`budget_model.dart`)
- [ ] Update `BudgetCategory` to include `monthlyBudget` and `budgetSpent`
- [ ] Add budget-aware percentage calculation

### Analytics Screen (`budget_analytics_screen.dart`)
- [ ] Fetch real category data with budgets from database
- [ ] Display budget limits in category rows
- [ ] Add budget setting UI (bottom sheet/dialog)
- [ ] Add progress bars for categories with budgets
- [ ] Show alerts when spending >= 80% or 100% of budget

## Verification
- [ ] Run `flutter analyze` - zero errors/warnings
- [ ] Test profile icon removal on all screens
- [ ] Test budget setting/editing functionality
- [ ] Test progress bars and alerts