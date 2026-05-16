<?php

namespace App\Jobs;

use App\Models\PreferencesUser;
use App\Models\PurchaseOrder;
use App\Models\StockMobile;
use App\Models\StockQuantity;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Carbon\Carbon;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Models\TrackingOrders;

class CheckExpiryOrders implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        /*
        try {
            DB::beginTransaction();
            $p_orders = PurchaseOrder::whereIn('state', ['new', 'in_way'])
                                     ->whereDate('planned_delivery_date', '<', Carbon::now()->addDays(-2))
                                     ->get();
            $ret = [];
            Log::info("Starting Process Checkng Expiry Order ------------------------------------");
            foreach($p_orders as $order){
                Log::info("$order->id : expired");
                foreach($order->orderitem as $orderitem){
                    if($order->state == "new"){
                        StockQuantity::AddPrevisionnelStockQuantity($order->warehouse_id,
                                                                    $orderitem->variant_id,
                                                                    $orderitem->unite == 'Cart' ?
                                                                                                  $orderitem->quantity * $orderitem->package
                                                                                                : $orderitem->quanity
                                                                    );
                    }else{
                        $emplacement = StockMobile::where("actor_id",  $order->actor_id)->first();
                        StockQuantity::UpdateRealStock($emplacement->id,
                                                        $orderitem->variant_id,
                                                        $orderitem->unite == 'Cart' ?
                                                                                    $orderitem->quantity * $orderitem->package
                                                                                  : $orderitem->quanity,
                                                                                  false, //to substrate quantity
                                                                                  true
                                                                                );



                        StockQuantity::UpdateRealStock($order->warehouse,
                        $orderitem->variant_id,
                        $orderitem->unite == 'Cart' ?
                                                      $orderitem->quantity * $orderitem->package
                                                    : $orderitem->quanity,
                                                    true,
                                                    true
                        );
                    }
                }
                $order->state = 'expired';
                $order->save();

                $to = TrackingOrders::where("purchaseorder_id", $order->id)->first();
                $to_id = "";
                if($to){
                    $old = explode("-",$to->id);
                    if(count($old)==5){
                        $to_id = $old[0] . "-" . $old[1] . "-" . $old[2] . "-" . $old[3] . "-" . $old[4] . "-" . "0";
                    }else if(count($old)==6){
                        $to_id = $old[0] . "-" . $old[1] . "-" . $old[2] . "-" . $old[3] . "-" . $old[4] . "-" . ($old[5]+1);
                    }
                }

                $purchaseOrder = TrackingOrders::create([
                    "id" => $to_id,
                    "order_id" => $order->order_id,
                    "purchaseorder_id" => $order->id,
                    "state" => "expired",
                    "amount" => $order->total_amount,
                    "actor_id" => $to->actor_id,
                    "is_last" => true,
                ]);
                $purchaseOrder->save();

            }
            Log::info("Finishing Process Checkng Expiry Order -------------------------------");
            DB::commit();

        }catch (\Exception $e) {
            Log::error($e->getMessage());
            DB::rollback();
        }
        */
    }
}
