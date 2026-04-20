---
name: signalr-realtime
description: Add or modify real-time SignalR hubs in ai_waiter.backend and the corresponding @microsoft/signalr client in the frontend
modelHint: research
---

# SignalR Real-Time Skill

## Repos: ai_waiter.backend (hub) + ai_waiter.frontend (client)

## Backend — Adding a Hub
```csharp
// AiWaiter.Api/Hubs/OrderHub.cs
using Microsoft.AspNetCore.SignalR;

public class OrderHub : Hub
{
    public async Task SendOrderUpdate(string orderId, string status)
    {
        await Clients.All.SendAsync("ReceiveOrderUpdate", orderId, status);
    }

    public async Task JoinOrderGroup(string orderId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"order-{orderId}");
    }
}
```

### Register in Program.cs
```csharp
builder.Services.AddSignalR();
// In app.MapXxx():
app.MapHub<OrderHub>("/hubs/orders");
```

### Send from a Service (Server Push)
```csharp
public class OrderService(IHubContext<OrderHub> hub) : IOrderService
{
    public async Task NotifyStatusChange(string orderId, string status)
    {
        await hub.Clients.Group($"order-{orderId}")
            .SendAsync("ReceiveOrderUpdate", orderId, status);
    }
}
```

## Frontend — Connecting to a Hub
```typescript
// src/lib/signalr.ts
import * as signalR from "@microsoft/signalr";

export function createOrderHubConnection(hubUrl: string) {
  return new signalR.HubConnectionBuilder()
    .withUrl(hubUrl)
    .withAutomaticReconnect()
    .configureLogging(signalR.LogLevel.Information)
    .build();
}
```

### Custom Hook
```typescript
// src/hooks/useOrderHub.ts
export function useOrderHub(orderId: string) {
  useEffect(() => {
    const conn = createOrderHubConnection(process.env.NEXT_PUBLIC_SIGNALR_URL!);
    conn.on("ReceiveOrderUpdate", (id, status) => { /* update store */ });
    conn.start().then(() => conn.invoke("JoinOrderGroup", orderId));
    return () => { conn.stop(); };
  }, [orderId]);
}
```
