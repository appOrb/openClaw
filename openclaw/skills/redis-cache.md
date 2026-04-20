---
name: redis-cache
description: Implement Redis caching patterns in the ai_waiter.backend Infrastructure layer
modelHint: repetitive
---

# Redis Cache Skill

## Repo: `appOrb/ai_waiter.backend` → `AiWaiter.Infrastructure/`
Uses Redis for caching. StackExchange.Redis or Microsoft.Extensions.Caching.StackExchangeRedis.

## Cache-Aside Pattern (Read-Through)
```csharp
// AiWaiter.Infrastructure/Services/CachedMenuItemService.cs
public class CachedMenuItemService(
    IMenuItemService inner,
    IDistributedCache cache,
    ILogger<CachedMenuItemService> logger) : IMenuItemService
{
    private const string CacheKey = "menu_items:all";
    private static readonly TimeSpan CacheTtl = TimeSpan.FromMinutes(15);

    public async Task<IEnumerable<MenuItemDto>> GetAllAsync(CancellationToken ct = default)
    {
        var cached = await cache.GetStringAsync(CacheKey, ct);
        if (cached is not null)
            return JsonSerializer.Deserialize<IEnumerable<MenuItemDto>>(cached)!;

        var result = await inner.GetAllAsync(ct);
        await cache.SetStringAsync(
            CacheKey,
            JsonSerializer.Serialize(result),
            new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = CacheTtl },
            ct);
        return result;
    }
}
```

## Register in DI (Infrastructure/DependencyInjection.cs)
```csharp
services.AddStackExchangeRedisCache(opts =>
{
    opts.Configuration = configuration.GetConnectionString("Redis");
});
// Decorator pattern:
services.AddScoped<MenuItemService>();
services.AddScoped<IMenuItemService>(sp =>
    new CachedMenuItemService(sp.GetRequiredService<MenuItemService>(), ...));
```

## Cache Invalidation
```csharp
await cache.RemoveAsync("menu_items:all", ct);
```

## Session/Short-Lived Keys
```csharp
// For order status (expires when order closes):
var key = $"order:status:{orderId}";
await cache.SetStringAsync(key, status,
    new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(2) }, ct);
```
