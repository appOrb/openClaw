---
name: dotnet-clean-arch
description: Add features to the ai_waiter.backend .NET 9 solution using Clean Architecture (Domain/Application/Infrastructure/Api layers)
modelHint: research
---

# .NET Clean Architecture Skill

## Repo: `appOrb/ai_waiter.backend`
Stack: .NET 9, C#, Clean Architecture, EF Core, SignalR, Serilog, Swashbuckle/OpenAPI, Newtonsoft.Json.

## Layer Structure
```
src/
  AiWaiter.Domain/          ← Entities, value objects, domain events, interfaces (no dependencies)
  AiWaiter.Application/     ← Use cases: DTOs, Mappings, Services, Plugins (depends on Domain only)
  AiWaiter.Infrastructure/  ← EF Core, Redis, external APIs (depends on Application interfaces)
  AiWaiter.Api/             ← Controllers, Hubs, Middleware, Auth (depends on Application)
tests/
  AiWaiter.UnitTests/
  AiWaiter.IntegrationTests/
```

## Adding a New Feature (e.g., "Menu Item")

### 1. Domain — Entity
```csharp
// AiWaiter.Domain/Entities/MenuItem.cs
public class MenuItem : BaseEntity
{
    public string Name { get; private set; }
    public decimal Price { get; private set; }
    // factory method, domain validation
}
```

### 2. Application — DTO + Service Interface
```csharp
// AiWaiter.Application/DTOs/MenuItemDto.cs
public record MenuItemDto(Guid Id, string Name, decimal Price);

// AiWaiter.Application/Services/IMenuItemService.cs
public interface IMenuItemService
{
    Task<IEnumerable<MenuItemDto>> GetAllAsync(CancellationToken ct = default);
    Task<MenuItemDto> CreateAsync(CreateMenuItemRequest request, CancellationToken ct = default);
}
```

### 3. Infrastructure — EF Core Implementation
```csharp
// AiWaiter.Infrastructure/Services/MenuItemService.cs
public class MenuItemService(AppDbContext db, IMapper mapper) : IMenuItemService { ... }
```

### 4. Api — Controller
```csharp
[ApiController, Route("api/[controller]")]
public class MenuItemsController(IMenuItemService service) : ControllerBase
{
    [HttpGet] public async Task<IActionResult> GetAll(CancellationToken ct) => Ok(await service.GetAllAsync(ct));
}
```

### 5. Register in DI (Infrastructure/DependencyInjection.cs)
```csharp
services.AddScoped<IMenuItemService, MenuItemService>();
```

## Logging Pattern
```csharp
private readonly ILogger<MyService> _logger;
_logger.LogInformation("Processing {ItemId}", itemId);
```

## Build & Test
```bash
dotnet build
dotnet test
dotnet run --project src/AiWaiter.Api
```
