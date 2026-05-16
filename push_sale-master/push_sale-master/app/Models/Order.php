<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;
use Exception;

class Order extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "order";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ["id", "code", "actor_id", "client_id", "total_amount", "residual", "order_date", "planned_delivery_date", "state"];

    public function orderitem()
    {
        return $this->hasMany(OrderItem::class, "order_id", "id");
    }

    public function client()
    {
        return $this->hasOne(Client::class, "id", "client_id");
    }

    public function tracking()
    {
        return $this->hasMany(TrackingOrders::class, "order_id", "id");
    }

    public function PurchaseOrders(){
        return $this->hasMany(PurchaseOrder::class, "order_id");
    }

    public function toPurchaseOrder($track_id)
    {
        try {
            $purchaseOrders = [];
            $total = [];
            $i = 0;
            $j = 0;
            foreach ($this->orderitem as $item) {
                if (!isset($purchaseOrders[$item->warehouse_id])) {
                    $purchaseOrders[$item->warehouse_id] = new PurchaseOrder();
                    $purchaseOrders[$item->warehouse_id]->id = $this->id . "-" . $i;
                    $purchaseOrders[$item->warehouse_id]->code = $this->code;
                    $purchaseOrders[$item->warehouse_id]->order_id = $this->id;
                    $purchaseOrders[$item->warehouse_id]->actor_id = null;
                    $purchaseOrders[$item->warehouse_id]->client_id = $this->client_id;
                    $purchaseOrders[$item->warehouse_id]->type = "invoice_out";
                    $purchaseOrders[$item->warehouse_id]->warehouse_id = $item->warehouse_id;
                    $purchaseOrders[$item->warehouse_id]->total_amount = 0;
                    $purchaseOrders[$item->warehouse_id]->purchase_date = $this->order_date;
                    $purchaseOrders[$item->warehouse_id]->planned_delivery_date = $this->planned_delivery_date;
                    $purchaseOrders[$item->warehouse_id]->delivery_date = null;
                    $purchaseOrders[$item->warehouse_id]->state = "new";

                    $total[$purchaseOrders[$item->warehouse_id]->id] = 0;
                    $i++;
                }
                $purchaseItem = new PurchaseOrderItem();
                $purchaseItem->id = $item->id . "-" . $j;
                $purchaseItem->purchaseorder_id = $purchaseOrders[$item->warehouse_id]->id;
                $purchaseItem->image = $item->image;
                $purchaseItem->product_name = $item->product_name;
                $purchaseItem->variant_name_1 = $item->variant_name_1;
                $purchaseItem->variant_name_2 = $item->variant_name_2;
                $purchaseItem->promotion_id = $item->promotion_id;
                $purchaseItem->promotionitem_id = $item->promotionitem_id;
                $purchaseItem->coupon_id = $item->coupon_id;
                $purchaseItem->unite = $item->unite;
                $purchaseItem->discount = $item->discount;
                $purchaseItem->variant_id = $item->variant_id;
                $purchaseItem->sku = $item->sku;
                $purchaseItem->quantity = $item->quantity;
                $purchaseItem->package = $item->package;
                $purchaseItem->price = $item->price;

                $total[$purchaseOrders[$item->warehouse_id]->id] += $item->price * $item->quantity;

                $purchaseItem->save();

                // $purchaseOrders[$item->warehouse_id]->orderitem()->add($purchaseItem);
                $j++;
            }
            $po = 0;
            foreach ($purchaseOrders as $purchaseOrder) {
                $purchaseOrder->total_amount = $total[$purchaseOrder->id];
                $purchaseOrder->residual = $total[$purchaseOrder->id];
                $track = TrackingOrders::where("id", $track_id . "-" . $po)->first();
                if (!$track) {
                    TrackingOrders::create([
                        "id" => $track_id . "-" . $po,
                        "order_id" => $this->id,
                        "purchaseorder_id" => $purchaseOrder->id,
                        "state" => "new",
                        "amount" => $purchaseOrder->total_amount,
                        "actor_id" => $this->actor_id,
                        "is_last" => false,
                    ]);
                    $purchaseOrder->save();
                }
            }
            return "done";
        } catch (Exception $e) {
            return $e->getMessage();
        }
    }
}
