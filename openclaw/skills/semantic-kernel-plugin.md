---
name: semantic-kernel-plugin
description: Add Semantic Kernel plugins and AI tools to the ai_waiter.backend Application/Plugins layer
modelHint: research
---

# Semantic Kernel Plugin Skill

## Repo: `appOrb/ai_waiter.backend` → `AiWaiter.Application/Plugins/`
Uses Semantic Kernel to expose domain operations as AI-callable tools.

## Plugin Structure
```
AiWaiter.Application/Plugins/
  MenuPlugin.cs           ← menu-related AI tools
  OrderPlugin.cs          ← order management tools
  RecommendationPlugin.cs ← AI recommendation tools
```

## Writing a Plugin
```csharp
// AiWaiter.Application/Plugins/MenuPlugin.cs
using Microsoft.SemanticKernel;

public class MenuPlugin(IMenuItemService menuService)
{
    [KernelFunction("get_available_items")]
    [Description("Get all available menu items with names and prices")]
    public async Task<string> GetAvailableItemsAsync(
        [Description("Optional category filter")] string? category = null)
    {
        var items = await menuService.GetAllAsync();
        var filtered = category is null ? items : items.Where(i => i.Category == category);
        return JsonSerializer.Serialize(filtered.Select(i => new { i.Name, i.Price, i.Description }));
    }

    [KernelFunction("add_item_to_order")]
    [Description("Add a menu item to an active order")]
    public async Task<string> AddItemAsync(
        [Description("The order ID")] string orderId,
        [Description("The menu item name")] string itemName,
        [Description("Quantity to add")] int quantity = 1)
    {
        // ...
        return $"Added {quantity}x {itemName} to order {orderId}";
    }
}
```

## Register Plugin in DI
```csharp
// AiWaiter.Infrastructure/DependencyInjection.cs
services.AddSingleton<MenuPlugin>();

// In Semantic Kernel setup:
var kernel = builder.Kernel;
kernel.Plugins.AddFromObject(sp.GetRequiredService<MenuPlugin>(), "Menu");
```

## Invoking a Plugin from a Service
```csharp
var result = await kernel.InvokeAsync("Menu", "get_available_items",
    new KernelArguments { ["category"] = "starters" });
Console.WriteLine(result.GetValue<string>());
```

## Testing Plugins
```csharp
[Fact]
public async Task GetAvailableItems_ReturnsJson()
{
    var mockService = Substitute.For<IMenuItemService>();
    mockService.GetAllAsync().Returns([new MenuItemDto(Guid.NewGuid(), "Burger", 12.99m)]);
    var plugin = new MenuPlugin(mockService);
    var result = await plugin.GetAvailableItemsAsync();
    var items = JsonSerializer.Deserialize<JsonElement[]>(result);
    Assert.Single(items!);
}
```
